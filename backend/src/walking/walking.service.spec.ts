import { Test, TestingModule } from '@nestjs/testing';
import { WalkingService } from './walking.service';

describe('WalkingService', () => {
  let service: WalkingService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [WalkingService],
    }).compile();

    service = module.get<WalkingService>(WalkingService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
