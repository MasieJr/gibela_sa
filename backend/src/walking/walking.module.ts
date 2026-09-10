import { Module } from '@nestjs/common';

import { WalkingService } from './walking.service';

@Module({
  providers: [WalkingService],
  exports: [WalkingService],
})
export class WalkingModule {}
