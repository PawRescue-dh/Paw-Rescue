import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Activity } from './activity.entity';
import { AuthUser } from '../auth/auth-user';

@Injectable()
export class ActivityService {
  private readonly logger = new Logger(ActivityService.name);

  constructor(
    @InjectRepository(Activity)
    private readonly repo: Repository<Activity>,
  ) {}

  /** Registrar una acción. Nunca debe tumbar la petición principal. */
  async log(type: string, message: string, actor?: Partial<AuthUser>, refId?: string) {
    try {
      await this.repo.save(
        this.repo.create({
          type,
          message,
          actorName: actor?.name ?? null,
          actorRole: actor?.role ?? null,
          refId: refId ?? null,
        }),
      );
    } catch (error) {
      this.logger.warn(`No se pudo registrar la actividad: ${String(error)}`);
    }
  }

  findRecent(limit = 100) {
    return this.repo.find({ order: { createdAt: 'DESC' }, take: Math.min(limit, 300) });
  }
}
