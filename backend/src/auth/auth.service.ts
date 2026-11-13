import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from './user.entity';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepo: Repository<User>,
    private jwtService: JwtService,
  ) {}

  async register(name: string, email: string, password: string, role: 'Ciudadano' | 'Albergue') {
    const cleanEmail = email.trim().toLowerCase();
    const exists = await this.usersRepo.findOne({ where: { email: cleanEmail } });
    if (exists) throw new ConflictException('El correo ya está registrado');

    const passwordHash = await bcrypt.hash(password, 10);
    const user = this.usersRepo.create({
      name,
      email: cleanEmail,
      passwordHash,
      role,
    });
    await this.usersRepo.save(user);

    return this.login(cleanEmail, password);
  }

  async login(email: string, password: string) {
    const cleanEmail = email.trim().toLowerCase();
    const user = await this.usersRepo.findOne({ where: { email: cleanEmail } });
    if (!user) throw new UnauthorizedException('Credenciales inválidas');

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) throw new UnauthorizedException('Credenciales inválidas');

    const payload = { sub: user.id, email: user.email, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    };
  }
}