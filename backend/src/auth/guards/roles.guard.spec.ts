import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { RolesGuard } from './roles.guard';
import { UserRole } from '../../database/entities';

describe('RolesGuard', () => {
  let guard: RolesGuard;
  let reflector: Reflector;

  beforeEach(() => {
    reflector = new Reflector();
    guard = new RolesGuard(reflector);
  });

  const createMockContext = (user?: { role?: UserRole }) => {
    return {
      getHandler: jest.fn<any>(),
      getClass: jest.fn<any>(),
      switchToHttp: jest.fn<any>().mockReturnValue({
        getRequest: jest.fn<any>().mockReturnValue({ user }),
      }),
    } as unknown as ExecutionContext;
  };

  it('debe permitir el acceso si la ruta no tiene roles requeridos', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(null);
    const context = createMockContext({ role: UserRole.Citizen });

    expect(guard.canActivate(context)).toBe(true);
  });

  it('debe permitir el acceso si el rol del usuario coincide con los requeridos', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([UserRole.Shelter]);
    const context = createMockContext({ role: UserRole.Shelter });

    expect(guard.canActivate(context)).toBe(true);
  });

  it('debe lanzar ForbiddenException si no hay usuario o no tiene rol', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([UserRole.Citizen]);
    const context = createMockContext(undefined);

    expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
  });

  it('debe lanzar ForbiddenException si el rol del usuario no coincide', () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue([UserRole.Shelter]);
    const context = createMockContext({ role: UserRole.Citizen });

    expect(() => guard.canActivate(context)).toThrow(ForbiddenException);
  });
});
