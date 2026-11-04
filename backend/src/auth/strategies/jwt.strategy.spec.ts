import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtStrategy } from './jwt.strategy';
import { UserRole } from '../../database/entities';

describe('JwtStrategy', () => {
  let strategy: JwtStrategy;
  let configService: ConfigService;

  beforeEach(() => {
    configService = {
      get: jest.fn<any>().mockReturnValue('test-secret'),
    } as unknown as ConfigService;

    strategy = new JwtStrategy(configService);
  });

  it('debe validar y retornar el usuario a partir del payload JWT', () => {
    const payload = {
      sub: 'uuid-123',
      email: 'user@example.com',
      role: UserRole.Citizen,
    };

    const result = strategy.validate(payload);

    expect(result).toEqual({
      userId: 'uuid-123',
      email: 'user@example.com',
      role: UserRole.Citizen,
    });
  });

  it('debe lanzar UnauthorizedException si el payload no contiene sub o email o role', () => {
    expect(() =>
      strategy.validate({ sub: '', email: 'user@example.com', role: UserRole.Citizen }),
    ).toThrow(UnauthorizedException);

    expect(() =>
      strategy.validate({ sub: 'uuid-123', email: '', role: UserRole.Citizen }),
    ).toThrow(UnauthorizedException);

    expect(() =>
      strategy.validate({ sub: 'uuid-123', email: 'user@example.com', role: undefined as any }),
    ).toThrow(UnauthorizedException);
  });
});
