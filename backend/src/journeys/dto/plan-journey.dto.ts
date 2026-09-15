import { IsLatitude, IsLongitude } from 'class-validator';
import { Type } from 'class-transformer';

export class PlanJourneyDto {
  @Type(() => Number)
  @IsLatitude()
  fromLat!: number;

  @Type(() => Number)
  @IsLongitude()
  fromLng!: number;

  @Type(() => Number)
  @IsLatitude()
  toLat!: number;

  @Type(() => Number)
  @IsLongitude()
  toLng!: number;
}
