import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { JwtAuthGuard } from './jwt-auth.guard';

const ctx = (authorization?: string) => {
  const req: any = { headers: authorization ? { authorization } : {} };
  return {
    req,
    context: { switchToHttp: () => ({ getRequest: () => req }) } as unknown as ExecutionContext,
  };
};

describe('JwtAuthGuard (seguridad)', () => {
  const jwt = new JwtService({ secret: 'test-secret', signOptions: { expiresIn: '1h' } });
  const guard = new JwtAuthGuard(jwt);

  it('rechaza peticiones sin token', async () => {
    await expect(guard.canActivate(ctx().context)).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rechaza esquemas distintos de Bearer', async () => {
    await expect(guard.canActivate(ctx('Basic abc').context)).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rechaza un token manipulado', async () => {
    const token = jwt.sign({ sub: '1', role: 'Ciudadano' });
    await expect(guard.canActivate(ctx(`Bearer ${token}x`).context)).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rechaza un token firmado con otro secreto', async () => {
    const forged = new JwtService({ secret: 'otro' }).sign({ sub: '1', role: 'Albergue' });
    await expect(guard.canActivate(ctx(`Bearer ${forged}`).context)).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('acepta un token válido y deja el usuario en la petición', async () => {
    const token = jwt.sign({ sub: '1', role: 'Albergue' });
    const { context, req } = ctx(`Bearer ${token}`);
    await expect(guard.canActivate(context)).resolves.toBe(true);
    expect(req.user.role).toBe('Albergue');
  });
});
