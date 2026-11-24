import { ForbiddenException } from '@nestjs/common';

export type Role = 'Ciudadano' | 'Albergue';

/** Datos que viajan dentro del JWT (req.user). */
export interface AuthUser {
  sub: string;
  email: string;
  role: Role;
  name?: string;
}

export function requireRole(user: AuthUser | undefined, role: Role): AuthUser {
  if (!user || user.role !== role) {
    throw new ForbiddenException(`Solo el rol ${role} puede realizar esta acción`);
  }
  return user;
}
