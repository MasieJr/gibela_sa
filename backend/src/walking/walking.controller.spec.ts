import { Test, TestingModule } from '@nestjs/testing';
import { WalkingController } from './walking.controller';
import { WalkingService } from './walking.service';

describe('WalkingController', () => {
  let controller: WalkingController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WalkingController],
      providers: [WalkingService],
    }).compile();

    controller = module.get<WalkingController>(WalkingController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
