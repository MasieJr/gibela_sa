import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class WalkingService {
  constructor(private readonly configService: ConfigService) {}

  async getWalkingRoute(
    fromLat: number,
    fromLng: number,
    toLat: number,
    toLng: number,
  ) {
    const apiKey = this.configService.get<string>('GEOAPIFY_API_KEY');

    if (!apiKey) {
      throw new Error('GEOAPIFY_API_KEY is not configured');
    }

    const params = new URLSearchParams({
      waypoints: `${fromLat},${fromLng}|${toLat},${toLng}`,
      mode: 'walk',
      format: 'geojson',
      apiKey,
    });

    try {
      const response = await fetch(
        `https://api.geoapify.com/v1/routing?${params}`,
      );

      if (!response.ok) {
        throw new Error(`Geoapify routing returned ${response.status}`);
      }

      const data = await response.json();

      const feature = data.features?.[0];

      if (!feature) {
        return null;
      }

      return {
        distanceMeters: feature.properties?.distance ?? 0,

        durationSeconds: feature.properties?.time ?? 0,

        geometry: feature.geometry,
      };
    } catch (error) {
      console.error('Walking route failed:', error);

      throw new BadGatewayException('Unable to calculate walking route');
    }
  }
}
