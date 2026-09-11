import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class SearchPlaceDto {
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  q!: string;
}
