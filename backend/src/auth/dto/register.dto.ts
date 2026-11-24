import {
  IsBoolean,
  IsEmail,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  @MaxLength(72)
  password: string;

  @IsIn(['Ciudadano', 'Albergue'])
  role: 'Ciudadano' | 'Albergue';

  /** Teléfono de contacto (10 a 15 dígitos, admite +, espacios y guiones). */
  @IsOptional()
  @Matches(/^[0-9+\s-]{10,20}$/, { message: 'Teléfono inválido' })
  phone?: string;

  /** El usuario aceptó el aviso de privacidad. */
  @IsOptional()
  @IsBoolean()
  acceptedPrivacy?: boolean;
}
