import { IsLatitude, IsLongitude } from 'class-validator';
import { Type } from 'class-transformer';

export class GetCurrentLocationDto {
  @Type(() => Number)
  @IsLatitude()
  fromLat!: number;

  @Type(() => Number)
  @IsLongitude()
  fromLng!: number;
}
