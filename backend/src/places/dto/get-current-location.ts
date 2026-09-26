import { IsLatitude, IsLongitude } from 'class-validator';
import { Type } from 'class-transformer';

export class GetCurrentLocationDto {
  @Type(() => Number)
  @IsLatitude()
  lat!: number;

  @Type(() => Number)
  @IsLongitude()
  lng!: number;
}
