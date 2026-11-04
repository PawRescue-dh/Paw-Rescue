import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    example: 'juan.perez@example.com',
    description: 'Correo electrónico registrado del usuario',
  })
  @IsEmail({}, { message: 'El formato del correo electrónico es inválido' })
  @IsNotEmpty({ message: 'El correo electrónico es obligatorio' })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  email: string;

  @ApiProperty({
    example: 'SecurePass123!',
    description: 'Contraseña del usuario',
  })
  @IsString({ message: 'La contraseña debe ser una cadena de texto' })
  @IsNotEmpty({ message: 'La contraseña es obligatoria' })
  password: string;
}
