import { IsIn, IsNotEmpty, IsOptional, IsString, Matches, MaxLength } from 'class-validator';

export class CreatePetDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  name: string;

  @IsIn(['Perro', 'Gato', 'Otro'])
  species: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(40)
  age: string;

  @IsIn(['Macho', 'Hembra'])
  sex: string;

  @IsIn(['Pequeño', 'Mediano', 'Grande'])
  size: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(1000)
  description: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  health: string;

  /** Si no se envía, se usa el teléfono del albergue que publica. */
  @IsOptional()
  @Matches(/^[0-9+\s-]{10,20}$/, { message: 'Teléfono inválido' })
  shelterPhone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(4_000_000)
  photoBase64?: string;
}
