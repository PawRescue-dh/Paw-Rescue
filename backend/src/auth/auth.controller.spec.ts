import { jest, describe, it, expect, beforeEach } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserRole } from '../database/entities';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import type { AuthenticatedUser } from './interfaces/jwt-payload.interface';

describe('AuthController', () => {
  let controller: AuthController;
  let authService: AuthService;

  const mockAuthService = {
    register: jest.fn<any>(),
    login: jest.fn<any>(),
    getProfile: jest.fn<any>(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: mockAuthService,
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    authService = module.get<AuthService>(AuthService);
  });

  it('debe estar definido', () => {
    expect(controller).toBeDefined();
  });

  describe('register', () => {
    it('debe llamar a authService.register y retornar la respuesta', async () => {
      const registerDto: RegisterDto = {
        name: 'Carlos Mendoza',
        email: 'carlos@example.com',
        password: 'Password123!',
        role: UserRole.Citizen,
      };

      const expectedResponse = {
        message: 'Usuario registrado exitosamente',
        user: {
          id: 'uuid-123',
          name: registerDto.name,
          email: registerDto.email,
          role: registerDto.role,
          createdAt: new Date(),
        },
        access_token: 'jwt-token',
      };

      mockAuthService.register.mockResolvedValue(expectedResponse);

      const result = await controller.register(registerDto);

      expect(authService.register).toHaveBeenCalledWith(registerDto);
      expect(result).toEqual(expectedResponse);
    });
  });

  describe('login', () => {
    it('debe llamar a authService.login y retornar el token', async () => {
      const loginDto: LoginDto = {
        email: 'carlos@example.com',
        password: 'Password123!',
      };

      const expectedResponse = {
        access_token: 'jwt-token',
        user: {
          id: 'uuid-123',
          name: 'Carlos Mendoza',
          email: 'carlos@example.com',
          role: UserRole.Citizen,
        },
      };

      mockAuthService.login.mockResolvedValue(expectedResponse);

      const result = await controller.login(loginDto);

      expect(authService.login).toHaveBeenCalledWith(loginDto);
      expect(result).toEqual(expectedResponse);
    });
  });

  describe('getProfile', () => {
    it('debe retornar el perfil del usuario autenticado', async () => {
      const currentUser: AuthenticatedUser = {
        userId: 'uuid-123',
        email: 'carlos@example.com',
        role: UserRole.Citizen,
      };

      const expectedProfile = {
        id: 'uuid-123',
        name: 'Carlos Mendoza',
        email: 'carlos@example.com',
        role: UserRole.Citizen,
        createdAt: new Date(),
      };

      mockAuthService.getProfile.mockResolvedValue(expectedProfile);

      const result = await controller.getProfile(currentUser);

      expect(authService.getProfile).toHaveBeenCalledWith(currentUser.userId);
      expect(result).toEqual(expectedProfile);
    });
  });

  describe('shelterOnly', () => {
    it('debe retornar el mensaje de bienvenida para rol Albergue', () => {
      const shelterUser: AuthenticatedUser = {
        userId: 'uuid-shelter',
        email: 'albergue@example.com',
        role: UserRole.Shelter,
      };

      const result = controller.shelterOnly(shelterUser);

      expect(result).toEqual({
        message: 'Bienvenido al panel exclusivo para albergues',
        user: shelterUser,
      });
    });
  });
});
