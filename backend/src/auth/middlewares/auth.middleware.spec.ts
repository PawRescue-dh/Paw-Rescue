import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { AuthMiddleware } from './auth.middleware';
import { UserRole } from '../../database/entities';

describe('AuthMiddleware', () => {
  let middleware: AuthMiddleware;
  let jwtService: JwtService;
  let configService: ConfigService;

  beforeEach(() => {
    jwtService = {
      verify: jest.fn<any>(),
    } as unknown as JwtService;

    configService = {
      get: jest.fn<any>().mockReturnValue('test-secret'),
    } as unknown as ConfigService;

    middleware = new AuthMiddleware(jwtService, configService);
  });

  it('debe permitir la solicitud y adjuntar req.user si el token es válido', () => {
    const req: any = {
      headers: {
        authorization: 'Bearer valid.jwt.token',
      },
    };
    const res: any = {};
    const next = jest.fn();

    const payload = {
      sub: 'uuid-123',
      email: 'user@example.com',
      role: UserRole.Citizen,
    };

    (jwtService.verify as any).mockReturnValue(payload);

    middleware.use(req, res, next);

    expect(jwtService.verify).toHaveBeenCalledWith('valid.jwt.token', {
      secret: 'test-secret',
    });
    expect(req.user).toEqual({
      userId: 'uuid-123',
      email: 'user@example.com',
      role: UserRole.Citizen,
    });
    expect(next).toHaveBeenCalled();
  });

  it('debe lanzar UnauthorizedException si no hay cabecera Authorization', () => {
    const req: any = { headers: {} };
    const res: any = {};
    const next = jest.fn();

    expect(() => middleware.use(req, res, next)).toThrow(
      UnauthorizedException,
    );
  });

  it('debe lanzar UnauthorizedException si la cabecera no empieza con Bearer', () => {
    const req: any = {
      headers: { authorization: 'Basic dXNlcjpwYXNz' },
    };
    const res: any = {};
    const next = jest.fn();

    expect(() => middleware.use(req, res, next)).toThrow(
      UnauthorizedException,
    );
  });

  it('debe lanzar UnauthorizedException si el token es inválido o falla la verificación', () => {
    const req: any = {
      headers: { authorization: 'Bearer invalid.token' },
    };
    const res: any = {};
    const next = jest.fn();

    (jwtService.verify as any).mockImplementation(() => {
      throw new Error('jwt expired');
    });

    expect(() => middleware.use(req, res, next)).toThrow(
      UnauthorizedException,
    );
  });
});
