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
    const { fromLat, fromLng, toLat, toLng } = dto;
    console.log(fromLat, fromLng, toLat, toLng);

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

      LIMIT 1
      `,
      [fromLng, fromLat, toLng, toLat],
    );

    if (result.rows.length === 0) {
      throw new NotFoundException('No direct taxi route found');
    }

    const route = result.rows[0];

    const [boardingLng, boardingLat] = route.boarding_point.coordinates;

    const [dropOffLng, dropOffLat] = route.dropoff_point.coordinates;

    const [walkingToTaxi, walkingToDestination] = await Promise.all([
      this.walkingService.getWalkingRoute(
        fromLat,
        fromLng,
        boardingLat,
        boardingLng,
      ),

      this.walkingService.getWalkingRoute(dropOffLat, dropOffLng, toLat, toLng),
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

      legs: [
        {
          type: 'walk',
          ...walkingToTaxi,
        },

        {
          type: 'taxi',
          geometry: route.journey_geometry,
        },

        {
          type: 'walk',
          ...walkingToDestination,
        },
      ],
    };
  }
}
