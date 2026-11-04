import {
  ConflictException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcryptjs';
import { User } from '../database/entities';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { BCRYPT_SALT_ROUNDS } from './constants';
import { JwtPayload } from './interfaces/jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const normalizedEmail = registerDto.email.trim().toLowerCase();

    const existingUser = await this.userRepository.findOne({
      where: { email: normalizedEmail },
    });

    if (existingUser) {
      throw new ConflictException('El correo ya está registrado');
    }

    const passwordHash = await hash(
      registerDto.password,
      BCRYPT_SALT_ROUNDS,
    );

    const user = this.userRepository.create({
      name: registerDto.name.trim(),
      email: normalizedEmail,
      passwordHash,
      role: registerDto.role,
    });

    const savedUser = await this.userRepository.save(user);

    const payload: JwtPayload = {
      sub: savedUser.id,
      email: savedUser.email,
      role: savedUser.role,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      message: 'Usuario registrado exitosamente',
      user: {
        id: savedUser.id,
        name: savedUser.name,
        email: savedUser.email,
        role: savedUser.role,
        createdAt: savedUser.createdAt,
      },
      access_token: accessToken,
    };
  }

  async login(loginDto: LoginDto) {
    const normalizedEmail = loginDto.email.trim().toLowerCase();

    const user = await this.userRepository
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .where('user.email = :email', { email: normalizedEmail })
      .getOne();

    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const isPasswordValid = await compare(
      loginDto.password,
      user.passwordHash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = this.jwtService.sign(payload);

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    };
  }

  async getProfile(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      createdAt: user.createdAt,
    };
  }
}

