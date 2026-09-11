import { Controller, Get, Query } from '@nestjs/common';

import { JourneysService } from './journeys.service';
import { PlanJourneyDto } from './dto/plan-journey.dto';

@Controller('journeys')
export class JourneysController {
  constructor(private readonly journeysService: JourneysService) {}

  @Get('plan')
  plan(@Query() query: PlanJourneyDto) {
    return this.journeysService.plan(query);
  }
}
