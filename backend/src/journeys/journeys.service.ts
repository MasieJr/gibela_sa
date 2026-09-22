import { Injectable, NotFoundException } from '@nestjs/common';

import { DatabaseService } from '../database/database.service';
import { WalkingService } from '../walking/walking.service';
import { PlanJourneyDto } from './dto/plan-journey.dto';

@Injectable()
export class JourneysService {
  constructor(
    private readonly database: DatabaseService,
    private readonly walkingService: WalkingService,
  ) {}

  async plan(dto: PlanJourneyDto) {
    const directJourneys = await this.findDirectJourneys(dto);
    console.log(dto);

    if (directJourneys.length > 0) {
      console.log('direct');
      return {
        journeys: directJourneys,
      };
    }

    const transferJourneys = await this.findOneTransferJourneys(dto);

    if (transferJourneys.length > 0) {
      console.log('direct');
      return {
        journeys: transferJourneys,
      };
    }

    throw new NotFoundException('No taxi journey found');
  }

  // Direct journey search
  private async findDirectJourneys(dto: PlanJourneyDto) {
    const { fromLat, fromLng, toLat, toLng } = dto;
    const result = await this.database.query(
      `
      WITH input AS (
        SELECT
          ST_SetSRID(
            ST_MakePoint($1, $2),
            4326
          ) AS user_point,

          ST_SetSRID(
            ST_MakePoint($3, $4),
            4326
          ) AS destination_point
      ),

      candidates AS (
        SELECT
          r.id,
          r.name,
          r.geometry,
          r.verified,
          r.fare,
          r.origin_rank_id,
          r.destination_rank_id,

          origin_rank.name AS origin_rank_name,
          destination_rank.name AS destination_rank_name,

          ST_LineLocatePoint(
            r.geometry,
            ST_ClosestPoint(
              r.geometry,
              input.user_point
            )
          ) AS board_position,

          ST_LineLocatePoint(
            r.geometry,
            ST_ClosestPoint(
              r.geometry,
              input.destination_point
            )
          ) AS dropoff_position,

          ST_Distance(
            r.geometry::geography,
            input.user_point::geography
          ) AS walking_to_route,

          ST_Distance(
            r.geometry::geography,
            input.destination_point::geography
          ) AS walking_from_route

        FROM public.routes r

        JOIN public.taxi_ranks origin_rank
          ON origin_rank.id = r.origin_rank_id

        JOIN public.taxi_ranks destination_rank
          ON destination_rank.id = r.destination_rank_id

        CROSS JOIN input

        WHERE
          r.geometry IS NOT NULL
          AND ST_DWithin(
            r.geometry::geography,
            input.user_point::geography,
            1500
          )
          AND ST_DWithin(
            r.geometry::geography,
            input.destination_point::geography,
            1500
          )
      )

      SELECT
        id,
        name,
        verified,
        fare,
        origin_rank_id,
        destination_rank_id,
        origin_rank_name,
        destination_rank_name,
        walking_to_route,
        walking_from_route,

        ST_AsGeoJSON(
          ST_LineInterpolatePoint(
            geometry,
            board_position
          )
        )::json AS boarding_point,
        ST_AsGeoJSON(
          ST_LineInterpolatePoint(
            geometry,
            dropoff_position
          )
        )::json AS dropoff_point,

        ST_AsGeoJSON(
          ST_LineSubstring(
            geometry,
            board_position,
            dropoff_position
          )
        )::json AS journey_geometry

      FROM candidates
      WHERE board_position < dropoff_position
      ORDER BY
        walking_to_route +
        walking_from_route ASC
      LIMIT 5
      `,
      [fromLng, fromLat, toLng, toLat],
    );
    if (result.rows.length === 0) {
      return [];
    }
    const journeys = await Promise.all(
      result.rows.map(async (route) => {
        const [boardingLng, boardingLat] = route.boarding_point.coordinates;

        const [dropOffLng, dropOffLat] = route.dropoff_point.coordinates;

        const [walkingToTaxi, walkingToDestination] = await Promise.all([
          this.walkingService.getWalkingRoute(
            fromLat,
            fromLng,
            boardingLat,
            boardingLng,
          ),

          this.walkingService.getWalkingRoute(
            dropOffLat,
            dropOffLng,
            toLat,
            toLng,
          ),
        ]);

        return {
          type: 'direct',

          origin: {
            latitude: fromLat,
            longitude: fromLng,
          },

          destination: {
            latitude: toLat,
            longitude: toLng,
          },

          boardingPoint: {
            latitude: boardingLat,
            longitude: boardingLng,
          },

          dropOffPoint: {
            latitude: dropOffLat,
            longitude: dropOffLng,
          },

          legs: [
            {
              type: 'walk',
              ...walkingToTaxi,
            },

            {
              type: 'taxi',

              geometry: route.journey_geometry,

              route: {
                id: route.id,
                name: route.name,

                originRank: {
                  id: route.origin_rank_id,
                  name: route.origin_rank_name,
                },

                destinationRank: {
                  id: route.destination_rank_id,
                  name: route.destination_rank_name,
                },

                fare: route.fare !== null ? Number(route.fare) : null,

                verified: route.verified,
              },
            },

            {
              type: 'walk',
              ...walkingToDestination,
            },
          ],
        };
      }),
    );

    journeys.sort((a, b) => {
      const aWalkingDistance = a.legs
        .filter((leg) => leg.type === 'walk')
        .reduce((total, leg) => total + (leg.distanceMeters ?? 0), 0);

      const bWalkingDistance = b.legs
        .filter((leg) => leg.type === 'walk')
        .reduce((total, leg) => total + (leg.distanceMeters ?? 0), 0);

      return aWalkingDistance - bWalkingDistance;
    });

    return journeys;
  }

  // One-transfer journey search
  private async findOneTransferJourneys(dto: PlanJourneyDto) {
    const { fromLat, fromLng, toLat, toLng } = dto;
    const result = await this.database.query(
      `
    WITH input AS (
      SELECT
        ST_SetSRID(
          ST_MakePoint($1, $2),
          4326
        ) AS user_point,

        ST_SetSRID(
          ST_MakePoint($3, $4),
          4326
        ) AS destination_point
    ),

    candidates AS (
      SELECT
        -- FIRST ROUTE
        first_route.id AS first_route_id,
        first_route.name AS first_route_name,
        first_route.geometry AS first_geometry,
        first_route.verified AS first_verified,
        first_route.fare AS first_fare,

        first_route.origin_rank_id
          AS first_origin_rank_id,

        first_route.destination_rank_id
          AS first_destination_rank_id,

        first_origin_rank.name
          AS first_origin_rank_name,

        transfer_rank.name
          AS transfer_rank_name,

        -- SECOND ROUTE
        second_route.id AS second_route_id,
        second_route.name AS second_route_name,
        second_route.geometry AS second_geometry,
        second_route.verified AS second_verified,
        second_route.fare AS second_fare,

        second_route.origin_rank_id
          AS second_origin_rank_id,

        second_route.destination_rank_id
          AS second_destination_rank_id,

        second_destination_rank.name
          AS second_destination_rank_name,

        -- USER BOARDING POSITION ON FIRST ROUTE
        ST_LineLocatePoint(
          first_route.geometry,
          ST_ClosestPoint(
            first_route.geometry,
            input.user_point
          )
        ) AS board_position,

        -- DESTINATION DROP-OFF POSITION
        -- ON SECOND ROUTE
        ST_LineLocatePoint(
          second_route.geometry,
          ST_ClosestPoint(
            second_route.geometry,
            input.destination_point
          )
        ) AS dropoff_position,

        -- STRAIGHT-LINE DISTANCES USED
        -- FOR INITIAL RANKING
        ST_Distance(
          first_route.geometry::geography,
          input.user_point::geography
        ) AS walking_to_route,

        ST_Distance(
          second_route.geometry::geography,
          input.destination_point::geography
        ) AS walking_from_route

      FROM public.routes first_route

      -- Route B must start where Route A ends
      JOIN public.routes second_route
        ON second_route.origin_rank_id =
           first_route.destination_rank_id

      JOIN public.taxi_ranks first_origin_rank
        ON first_origin_rank.id =
           first_route.origin_rank_id

      JOIN public.taxi_ranks transfer_rank
        ON transfer_rank.id =
           first_route.destination_rank_id

      JOIN public.taxi_ranks second_destination_rank
        ON second_destination_rank.id =
           second_route.destination_rank_id

      CROSS JOIN input

      WHERE
        first_route.geometry IS NOT NULL

        AND second_route.geometry IS NOT NULL

        -- Route A must pass close enough
        -- to the user's starting point
        AND ST_DWithin(
          first_route.geometry::geography,
          input.user_point::geography,
          1500
        )

        -- Route B must pass close enough
        -- to the user's destination
        AND ST_DWithin(
          second_route.geometry::geography,
          input.destination_point::geography,
          1500
        )

        -- Don't connect a route to itself
        AND first_route.id <> second_route.id
    )

    SELECT
      *,

      -- Boarding point on Route A
      ST_AsGeoJSON(
        ST_LineInterpolatePoint(
          first_geometry,
          board_position
        )
      )::json AS boarding_point,

      -- Route A:
      -- boarding point -> transfer rank
      ST_AsGeoJSON(
        ST_LineSubstring(
          first_geometry,
          board_position,
          1.0
        )
      )::json AS first_journey_geometry,

      -- Route B:
      -- transfer rank -> destination drop-off
      ST_AsGeoJSON(
        ST_LineSubstring(
          second_geometry,
          0.0,
          dropoff_position
        )
      )::json AS second_journey_geometry,

      -- Drop-off point on Route B
      ST_AsGeoJSON(
        ST_LineInterpolatePoint(
          second_geometry,
          dropoff_position
        )
      )::json AS dropoff_point

    FROM candidates

    WHERE
      -- User must board Route A before its end
      board_position < 1.0

      -- Destination must occur after
      -- Route B starts
      AND dropoff_position > 0.0

    ORDER BY
      walking_to_route +
      walking_from_route ASC

    LIMIT 5
    `,
      [fromLng, fromLat, toLng, toLat],
    );

    if (result.rows.length === 0) {
      return [];
    }

    const journeys = await Promise.all(
      result.rows.map(async (route) => {
        const [boardingLng, boardingLat] = route.boarding_point.coordinates;

        const [dropOffLng, dropOffLat] = route.dropoff_point.coordinates;

        const [walkingToTaxi, walkingToDestination] = await Promise.all([
          this.walkingService.getWalkingRoute(
            fromLat,
            fromLng,
            boardingLat,
            boardingLng,
          ),

          this.walkingService.getWalkingRoute(
            dropOffLat,
            dropOffLng,
            toLat,
            toLng,
          ),
        ]);

        return {
          type: 'transfer',

          origin: {
            latitude: fromLat,
            longitude: fromLng,
          },

          destination: {
            latitude: toLat,
            longitude: toLng,
          },

          boardingPoint: {
            latitude: boardingLat,
            longitude: boardingLng,
          },

          dropOffPoint: {
            latitude: dropOffLat,
            longitude: dropOffLng,
          },

          legs: [
            {
              type: 'walk',
              ...walkingToTaxi,
            },

            {
              type: 'taxi',

              geometry: route.first_journey_geometry,

              route: {
                id: route.first_route_id,
                name: route.first_route_name,

                originRank: {
                  id: route.first_origin_rank_id,
                  name: route.first_origin_rank_name,
                },

                destinationRank: {
                  id: route.first_destination_rank_id,
                  name: route.transfer_rank_name,
                },

                fare:
                  route.first_fare !== null ? Number(route.first_fare) : null,

                verified: route.first_verified,
              },
            },

            {
              type: 'taxi',

              geometry: route.second_journey_geometry,

              route: {
                id: route.second_route_id,
                name: route.second_route_name,

                originRank: {
                  id: route.second_origin_rank_id,
                  name: route.transfer_rank_name,
                },

                destinationRank: {
                  id: route.second_destination_rank_id,
                  name: route.second_destination_rank_name,
                },

                fare:
                  route.second_fare !== null ? Number(route.second_fare) : null,

                verified: route.second_verified,
              },
            },

            {
              type: 'walk',
              ...walkingToDestination,
            },
          ],
        };
      }),
    );
    journeys.sort((a, b) => {
      const aWalkingDistance = a.legs
        .filter((leg) => leg.type === 'walk')
        .reduce((total, leg) => total + (leg.distanceMeters ?? 0), 0);

      const bWalkingDistance = b.legs
        .filter((leg) => leg.type === 'walk')
        .reduce((total, leg) => total + (leg.distanceMeters ?? 0), 0);

      return aWalkingDistance - bWalkingDistance;
    });

    return journeys;
  }
}
