import {
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';
import { UserRole } from '../../database/entities';

export class RegisterDto {
  @ApiProperty({
    example: 'Juan Pérez',
    description: 'Nombre completo del usuario',
    maxLength: 100,
  })
  @IsString({ message: 'El nombre debe ser una cadena de texto' })
  @IsNotEmpty({ message: 'El nombre es obligatorio' })
  @MaxLength(100, { message: 'El nombre no debe exceder 100 caracteres' })
  name: string;

  @ApiProperty({
    example: 'juan.perez@example.com',
    description: 'Correo electrónico único del usuario',
    maxLength: 254,
  })
  @IsEmail({}, { message: 'El formato del correo electrónico es inválido' })
  @IsNotEmpty({ message: 'El correo electrónico es obligatorio' })
  @MaxLength(254, { message: 'El correo electrónico no debe exceder 254 caracteres' })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email: string;

  @ApiProperty({
    example: 'SecurePass123!',
    description:
      'Contraseña de al menos 8 caracteres con al menos 1 número y 1 carácter especial',
    minLength: 8,
    maxLength: 72,
  })
  @IsString({ message: 'La contraseña debe ser una cadena de texto' })
  @IsNotEmpty({ message: 'La contraseña es obligatoria' })
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  @MaxLength(72, { message: 'La contraseña no puede exceder 72 caracteres' })
  @Matches(/^(?=.*[0-9])(?=.*[^A-Za-z0-9\s]).{8,}$/, {
    message:
      'La contraseña debe tener mínimo 8 caracteres, al menos 1 número y al menos 1 carácter especial',
  })
  password: string;

  @ApiProperty({
    enum: UserRole,
    example: UserRole.Citizen,
    description: 'Rol del usuario (Ciudadano o Albergue)',
  })
  @IsEnum(UserRole, {
    message: 'El rol debe ser Ciudadano o Albergue',
  })
  @IsNotEmpty({ message: 'El rol es obligatorio' })
  role: UserRole;
}
