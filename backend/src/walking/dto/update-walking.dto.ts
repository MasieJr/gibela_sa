import { PartialType } from '@nestjs/mapped-types';
import { CreateWalkingDto } from './create-walking.dto';

export class UpdateWalkingDto extends PartialType(CreateWalkingDto) {}
