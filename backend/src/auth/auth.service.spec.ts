import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { User } from './user.entity';

describe('AuthService', () => {
  let service: AuthService;
  const repo = { findOne: jest.fn(), create: jest.fn((x) => x), save: jest.fn() };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: repo },
        { provide: JwtService, useValue: { sign: jest.fn(() => 'mock_token') } },
      ],
    }).compile();
    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('login devuelve token y usuario con credenciales correctas', async () => {
    const passwordHash = await bcrypt.hash('Password123!', 4);
    repo.findOne.mockResolvedValue({ id: '1', name: 'Ana', email: 'ana@pawrescue.com', role: 'Ciudadano', passwordHash });
    const r = await service.login(' ANA@pawrescue.com ', 'Password123!');
    expect(r.access_token).toBe('mock_token');
    expect(r.user).toEqual({ id: '1', name: 'Ana', email: 'ana@pawrescue.com', role: 'Ciudadano' });
    expect(r.user).not.toHaveProperty('passwordHash');
  });

  it('login falla con contraseña incorrecta', async () => {
    const passwordHash = await bcrypt.hash('Password123!', 4);
    repo.findOne.mockResolvedValue({ id: '1', email: 'a@b.com', role: 'Ciudadano', passwordHash });
    await expect(service.login('a@b.com', 'mala')).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('login falla si el usuario no existe', async () => {
    repo.findOne.mockResolvedValue(null);
    await expect(service.login('x@y.com', 'abc')).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('register rechaza correos duplicados', async () => {
    repo.findOne.mockResolvedValue({ id: '1' });
    await expect(service.register('Ana', 'a@b.com', 'Password123!', 'Ciudadano')).rejects.toBeInstanceOf(ConflictException);
  });

  it('register guarda la contraseña con hash bcrypt, nunca en texto plano', async () => {
    repo.findOne.mockResolvedValueOnce(null);
    repo.findOne.mockImplementationOnce(() => Promise.resolve(repo.create.mock.results[0].value));
    await service.register('Ana', 'a@b.com', 'Password123!', 'Ciudadano');
    const saved = repo.create.mock.calls[0][0];
    expect(saved.passwordHash).not.toBe('Password123!');
    expect(await bcrypt.compare('Password123!', saved.passwordHash)).toBe(true);
  });
});
