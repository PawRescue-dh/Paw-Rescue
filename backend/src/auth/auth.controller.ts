import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RolesGuard } from './guards/roles.guard';
import { Roles } from './decorators/roles.decorator';
import { CurrentUser } from './decorators/current-user.decorator';
import type { AuthenticatedUser } from './interfaces/jwt-payload.interface';
import { UserRole } from '../database/entities';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({
    summary: 'Registrar un nuevo usuario',
    description:
      'Permite el registro de ciudadanos o albergues validando contraseña y duplicidad de correo.',
  })
  @ApiCreatedResponse({
    description: 'Usuario registrado exitosamente y token retornado.',
  })
  @ApiConflictResponse({ description: 'El correo electrónico ya está registrado.' })
  async register(@Body() registerDto: RegisterDto) {
    return await this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Iniciar sesión',
    description:
      'Autentica las credenciales del usuario y retorna un token JWT válido por 24 horas.',
  })
  @ApiOkResponse({ description: 'Inicio de sesión exitoso con token JWT.' })
  @ApiUnauthorizedResponse({ description: 'Credenciales inválidas.' })
  async login(@Body() loginDto: LoginDto) {
    return await this.authService.login(loginDto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('jwt-auth')
  @ApiOperation({
    summary: 'Obtener perfil del usuario autenticado',
    description: 'Ruta protegida por JWT que retorna la información del usuario.',
  })
  @ApiOkResponse({ description: 'Perfil de usuario obtenido correctamente.' })
  @ApiUnauthorizedResponse({ description: 'Token no proporcionado o inválido.' })
  @ApiNotFoundResponse({ description: 'Usuario no encontrado.' })
  async getProfile(@CurrentUser() user: AuthenticatedUser) {
    return await this.authService.getProfile(user.userId);
  }

  @Get('shelter-only')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.Shelter)
  @ApiBearerAuth('jwt-auth')
  @ApiOperation({
    summary: 'Ruta exclusiva para albergues',
    description:
      'Demostración de control de acceso por roles: sólo usuarios con rol Albergue pueden acceder.',
  })
  @ApiOkResponse({ description: 'Acceso autorizado para rol Albergue.' })
  @ApiForbiddenResponse({
    description: 'Acceso restringido: se requiere rol Albergue.',
  })
  shelterOnly(@CurrentUser() user: AuthenticatedUser) {
    return {
      message: 'Bienvenido al panel exclusivo para albergues',
      user,
    };
  }
}
