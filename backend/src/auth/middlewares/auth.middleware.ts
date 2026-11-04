import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { DEFAULT_JWT_SECRET } from '../constants';
import { JwtPayload } from '../interfaces/jwt-payload.interface';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  use(req: Request, _res: Response, next: NextFunction): void {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Token de autenticación no proporcionado en la cabecera Authorization',
      );
    }

    const token = authHeader.substring(7).trim();
    if (!token) {
      throw new UnauthorizedException('Token de autenticación vacío');
    }

    try {
      const secret =
        this.configService.get<string>('JWT_SECRET') ?? DEFAULT_JWT_SECRET;
      const payload = this.jwtService.verify<JwtPayload>(token, { secret });

      (req as any).user = {
        userId: payload.sub,
        email: payload.email,
        role: payload.role,
      };

      next();
    } catch {
      throw new UnauthorizedException(
        'Token de autenticación inválido o expirado',
      );
    }
  }
}

