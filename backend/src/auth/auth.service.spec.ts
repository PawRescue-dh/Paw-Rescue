import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { hash } from 'bcryptjs';
import { AuthService } from './auth.service';
import { User, UserRole } from '../database/entities';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { BCRYPT_SALT_ROUNDS } from './constants';

describe('AuthService', () => {
  let authService: AuthService;
  let jwtService: JwtService;

  let existingHashedPassword: string;

  const mockQueryBuilder = {
    addSelect: jest.fn<any>().mockReturnThis(),
    where: jest.fn<any>().mockReturnThis(),
    getOne: jest.fn<any>(),
  };

  const mockUserRepository = {
    findOne: jest.fn<any>(),
    create: jest.fn<any>(),
    save: jest.fn<any>(),
    createQueryBuilder: jest.fn<any>(() => mockQueryBuilder),
  };

  const mockJwtService = {
    sign: jest.fn<any>().mockReturnValue('mock.jwt.token'),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    existingHashedPassword = await hash('Password123!', BCRYPT_SALT_ROUNDS);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('debe estar definido', () => {
    expect(authService).toBeDefined();
  });

  describe('register', () => {
    const registerDto: RegisterDto = {
      name: ' Juan Perez ',
      email: ' Juan@Example.com ',
      password: 'Password123!',
      role: UserRole.Citizen,
    };

    it('debe registrar un usuario exitosamente cifrando la contraseña con bcrypt (coste >= 10)', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);
      mockUserRepository.create.mockImplementation((userData: any) => userData);
      mockUserRepository.save.mockImplementation(async (userData: any) => ({
        id: '123e4567-e89b-12d3-a456-426614174000',
        ...userData,
        createdAt: new Date(),
      }));

      const result = await authService.register(registerDto);

      expect(mockUserRepository.findOne).toHaveBeenCalledWith({
        where: { email: 'juan@example.com' },
      });
      expect(BCRYPT_SALT_ROUNDS).toBeGreaterThanOrEqual(10);
      expect(mockUserRepository.create).toHaveBeenCalled();
      const createdUserData = mockUserRepository.create.mock.calls[0][0];
      expect(createdUserData.name).toBe('Juan Perez');
      expect(createdUserData.email).toBe('juan@example.com');
      expect(createdUserData.role).toBe(UserRole.Citizen);
      // Validar que la contraseña fue cifrada con factor de coste >= 10
      expect(createdUserData.passwordHash).toMatch(/^\$2[ab]\$10\$/);
      expect(createdUserData.passwordHash).not.toBe('Password123!');

      expect(mockUserRepository.save).toHaveBeenCalled();
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: '123e4567-e89b-12d3-a456-426614174000',
        email: 'juan@example.com',
        role: UserRole.Citizen,
      });

      expect(result.message).toBe('Usuario registrado exitosamente');
      expect(result.access_token).toBe('mock.jwt.token');
      expect(result.user.name).toBe('Juan Perez');
      expect(result.user.email).toBe('juan@example.com');
      expect(result.user.role).toBe(UserRole.Citizen);
      expect((result.user as any).passwordHash).toBeUndefined();
    });

    it('debe lanzar ConflictException si el correo ya está registrado', async () => {
      mockUserRepository.findOne.mockResolvedValue({
        id: 'existing-id',
        email: 'juan@example.com',
      });

      await expect(authService.register(registerDto)).rejects.toThrow(
        ConflictException,
      );
      expect(mockUserRepository.findOne).toHaveBeenCalledWith({
        where: { email: 'juan@example.com' },
      });
      expect(mockUserRepository.save).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    const loginDto: LoginDto = {
      email: ' JUAN@example.com ',
      password: 'Password123!',
    };

    it('debe iniciar sesión exitosamente y retornar token JWT y datos de usuario', async () => {
      const mockUserDb = {
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Juan Perez',
        email: 'juan@example.com',
        passwordHash: existingHashedPassword,
        role: UserRole.Citizen,
        createdAt: new Date(),
      };

      mockQueryBuilder.getOne.mockResolvedValue(mockUserDb);

      const result = await authService.login(loginDto);

      expect(mockUserRepository.createQueryBuilder).toHaveBeenCalledWith('user');
      expect(mockQueryBuilder.addSelect).toHaveBeenCalledWith('user.passwordHash');
      expect(mockQueryBuilder.where).toHaveBeenCalledWith('user.email = :email', {
        email: 'juan@example.com',
      });
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: mockUserDb.id,
        email: mockUserDb.email,
        role: mockUserDb.role,
      });
      expect(result).toEqual({
        access_token: 'mock.jwt.token',
        user: {
          id: mockUserDb.id,
          name: mockUserDb.name,
          email: mockUserDb.email,
          role: mockUserDb.role,
        },
      });
    });

    it('debe lanzar UnauthorizedException si el usuario no existe', async () => {
      mockQueryBuilder.getOne.mockResolvedValue(null);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('debe lanzar UnauthorizedException si la contraseña es incorrecta', async () => {
      const mockUserDb = {
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Juan Perez',
        email: 'juan@example.com',
        passwordHash: existingHashedPassword,
        role: UserRole.Citizen,
        createdAt: new Date(),
      };

      mockQueryBuilder.getOne.mockResolvedValue(mockUserDb);

      await expect(
        authService.login({
          email: 'juan@example.com',
          password: 'WrongPassword!',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('getProfile', () => {
    it('debe retornar el perfil del usuario si existe', async () => {
      const mockUserDb = {
        id: '123e4567-e89b-12d3-a456-426614174000',
        name: 'Juan Perez',
        email: 'juan@example.com',
        passwordHash: existingHashedPassword,
        role: UserRole.Citizen,
        createdAt: new Date(),
      };

      mockUserRepository.findOne.mockResolvedValue(mockUserDb);

      const result = await authService.getProfile(mockUserDb.id);

      expect(mockUserRepository.findOne).toHaveBeenCalledWith({
        where: { id: mockUserDb.id },
      });
      expect(result).toEqual({
        id: mockUserDb.id,
        name: mockUserDb.name,
        email: mockUserDb.email,
        role: mockUserDb.role,
        createdAt: mockUserDb.createdAt,
      });
    });

    it('debe lanzar NotFoundException si el usuario no existe', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(authService.getProfile('non-existent-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
