import { Module } from '@nestjs/common';

import { JourneysController } from './journeys.controller';
import { JourneysService } from './journeys.service';
import { WalkingModule } from '../walking/walking.module';

@Module({
  imports: [WalkingModule],
  controllers: [JourneysController],
  providers: [JourneysService],
})
export class JourneysModule {}
