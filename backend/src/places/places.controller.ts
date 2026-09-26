import { Controller, Get, Query } from '@nestjs/common';

import { PlacesService } from './places.service';
import { SearchPlaceDto } from './dto/search-place.dto';
import { GetCurrentLocationDto } from './dto/get-current-location';

@Controller('places')
export class PlacesController {
  constructor(private readonly placesService: PlacesService) {}

  @Get('search')
  search(@Query() query: SearchPlaceDto) {
    return this.placesService.search(query.q);
  }

  @Get('current')
  current(@Query() query: GetCurrentLocationDto) {
    return this.placesService.current(query);
  }
}
