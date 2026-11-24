import { IsOptional, IsString, Matches, MaxLength } from 'class-validator';

export class AdoptPetDto {
  @Matches(/^[0-9+\s-]{10,20}$/, { message: 'Teléfono inválido' })
  phone: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  message?: string;
}
