import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PlacesService {
  constructor(private readonly configService: ConfigService) {}

  async search(query: string) {
    const apiKey = this.configService.get<string>('GEOAPIFY_API_KEY');

    if (!apiKey) {
      throw new Error('GEOAPIFY_API_KEY is not configured');
    }

    const params = new URLSearchParams({
      text: query,
      filter: 'countrycode:za',
      bias: 'countrycode:za',
      format: 'json',
      limit: '8',
      apiKey,
    });

    try {
      const response = await fetch(
        `https://api.geoapify.com/v1/geocode/search?${params}`,
      );

      if (!response.ok) {
        throw new Error(`Geoapify returned ${response.status}`);
      }

      const data = await response.json();

      return data.results.map((place: any) => ({
        placeId: place.place_id,
        name: place.name ?? place.address_line1 ?? place.formatted,
        address: place.formatted,
        latitude: place.lat,
        longitude: place.lon,
        category: place.result_type,
      }));
    } catch (error) {
      console.error('Geoapify search failed:', error);

      throw new BadGatewayException('Unable to search destinations');
    }
  }
}
