import { Injectable } from '@nestjs/common';
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

    return result.rows;
  }
}
