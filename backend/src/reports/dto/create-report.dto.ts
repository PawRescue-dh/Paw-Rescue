import { IsIn, IsNotEmpty, IsNumber, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';

export class CreateReportDto {
  @IsIn(['Perro', 'Gato', 'Otro'])
  species: string;

  @IsIn(['Baja', 'Media', 'Alta', 'Crítica'])
  urgency: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(1000)
  description: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @IsOptional()
  @IsString()
  @MaxLength(8_000_000)
  photoBase64?: string;
}
