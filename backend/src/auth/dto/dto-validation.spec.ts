import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { RegisterDto } from './register.dto';
import { LoginDto } from './login.dto';
import { UserRole } from '../../database/entities';

describe('DTO Validations', () => {
  describe('RegisterDto', () => {
    it('debe ser válido con datos correctos para Ciudadano', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'maria@example.com',
        password: 'ValidPass1!',
        role: UserRole.Citizen,
      });

      const errors = await validate(dto);
      expect(errors.length).toBe(0);
    });

    it('debe ser válido con datos correctos para Albergue', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Albergue Esperanza',
        email: 'contacto@esperanza.org',
        password: 'Albergue2026#',
        role: UserRole.Shelter,
      });

      const errors = await validate(dto);
      expect(errors.length).toBe(0);
    });

    it('debe rechazar contraseñas con menos de 8 caracteres', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'maria@example.com',
        password: 'Sh1!',
        role: UserRole.Citizen,
      });

      const errors = await validate(dto);
      const passwordErrors = errors.find((e) => e.property === 'password');
      expect(passwordErrors).toBeDefined();
    });

    it('debe rechazar contraseñas sin número', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'maria@example.com',
        password: 'Password!',
        role: UserRole.Citizen,
      });

      const errors = await validate(dto);
      const passwordErrors = errors.find((e) => e.property === 'password');
      expect(passwordErrors).toBeDefined();
    });

    it('debe rechazar contraseñas sin carácter especial', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'maria@example.com',
        password: 'Password123',
        role: UserRole.Citizen,
      });

      const errors = await validate(dto);
      const passwordErrors = errors.find((e) => e.property === 'password');
      expect(passwordErrors).toBeDefined();
    });

    it('debe rechazar roles inválidos que no sean Ciudadano ni Albergue', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'maria@example.com',
        password: 'Password123!',
        role: 'Admin',
      });

      const errors = await validate(dto);
      const roleErrors = errors.find((e) => e.property === 'role');
      expect(roleErrors).toBeDefined();
    });

    it('debe rechazar correos con formato inválido', async () => {
      const dto = plainToInstance(RegisterDto, {
        name: 'Maria Lopez',
        email: 'not-an-email',
        password: 'Password123!',
        role: UserRole.Citizen,
      });

      const errors = await validate(dto);
      const emailErrors = errors.find((e) => e.property === 'email');
      expect(emailErrors).toBeDefined();
    });
  });

  describe('LoginDto', () => {
    it('debe ser válido con correo y contraseña correctos', async () => {
      const dto = plainToInstance(LoginDto, {
        email: 'test@example.com',
        password: 'Password123!',
      });

      const errors = await validate(dto);
      expect(errors.length).toBe(0);
    });

    it('debe fallar si falta el correo o la contraseña', async () => {
      const dto = plainToInstance(LoginDto, {
        email: '',
        password: '',
      });

      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
    });
  });
});

