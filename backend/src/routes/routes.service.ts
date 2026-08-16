import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class RoutesService {
  constructor(private readonly database: DatabaseService) {}

  async findAll() {
    const result = await this.database.query(`
      SELECT
        id,
        name,
        origin,
        destination,
        ST_AsGeoJSON(geometry) AS geometry,
        status,
        created_at,
        updated_at
      FROM taxi_routes
      ORDER BY name ASC
    `);

    result.rows.forEach((route) => {
      route.geometry = JSON.parse(route.geometry);
    });

    return result.rows;
  }

  async findOne(id: string) {
    const result = await this.database.query(
      `
      SELECT
        id,
        name,
        origin,
        destination,
        ST_AsGeoJSON(geometry) AS geometry,
        status,
        created_at,
        updated_at
      FROM taxi_routes
      WHERE id = $1
      `,
      [id],
    );

    if (result.rows.length === 0) {
      throw new NotFoundException(`Taxi route with ID ${id} not found`);
    }

    const route = result.rows[0];

    route.geometry = JSON.parse(route.geometry);

    return route;
  }
}
