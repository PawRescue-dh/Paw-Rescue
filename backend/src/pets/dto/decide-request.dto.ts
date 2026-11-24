import { IsIn } from 'class-validator';

export class DecideRequestDto {
  @IsIn(['Aprobada', 'Rechazada'])
  status: 'Aprobada' | 'Rechazada';
}
