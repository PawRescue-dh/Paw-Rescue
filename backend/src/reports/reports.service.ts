import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from './report.entity';
import { ReportComment } from './report-comment.entity';
import { ActivityService } from '../activity/activity.service';
import { AuthUser } from '../auth/auth-user';

const LIST_FIELDS = {
  id: true,
  species: true,
  urgency: true,
  description: true,
  latitude: true,
  longitude: true,
  status: true,
  reporterId: true,
  reporterName: true,
  createdAt: true,
} as const;

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Report)
    private readonly reportRepo: Repository<Report>,
    @InjectRepository(ReportComment)
    private readonly commentRepo: Repository<ReportComment>,
    private readonly activity: ActivityService,
  ) {}

  async create(
    data: {
      species: string;
      urgency: string;
      description: string;
      latitude: number;
      longitude: number;
      photoBase64?: string;
    },
    user?: AuthUser,
  ) {
    const report = this.reportRepo.create({
      species: data.species,
      urgency: data.urgency,
      description: data.description,
      latitude: data.latitude,
      longitude: data.longitude,
      photoBase64: data.photoBase64 || '',
      reporterId: user?.sub ?? null,
      reporterName: user?.name ?? null,
      location: {
        type: 'Point',
        coordinates: [data.longitude, data.latitude],
      },
    });

    const saved = await this.reportRepo.save(report);
    await this.activity.log(
      'reporte',
      `Nuevo reporte de ${data.species} con urgencia ${data.urgency}`,
      user,
      saved.id,
    );
    // La respuesta no devuelve la foto para no reenviar el payload completo.
    const { photoBase64: _photo, ...rest } = saved;
    return rest;
  }

  /** Albergue: todos los reportes. Ciudadano: solo los suyos. Sin foto y limitado. */
  async findAll(user?: AuthUser, limit = 200) {
    const isShelter = user?.role === 'Albergue';
    return await this.reportRepo.find({
      select: LIST_FIELDS,
      where: isShelter ? {} : { reporterId: user?.sub ?? '00000000-0000-0000-0000-000000000000' },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  private assertAccess(report: Report, user?: AuthUser) {
    if (user?.role === 'Albergue') return;
    if (user && report.reporterId && report.reporterId === user.sub) return;
    throw new ForbiddenException('No tienes acceso a este reporte');
  }

  async findOne(id: string, user?: AuthUser) {
    const report = await this.reportRepo.findOne({ where: { id } });
    if (!report) throw new NotFoundException('Reporte no encontrado');
    this.assertAccess(report, user);
    return report;
  }

  async updateStatus(id: string, status: string, user?: AuthUser) {
    const report = await this.reportRepo.findOne({ where: { id } });
    if (!report) throw new NotFoundException('Reporte no encontrado');
    report.status = status;
    const saved = await this.reportRepo.save(report);
    await this.activity.log(
      'estado',
      `Reporte de ${saved.species} (${saved.urgency}) cambió a "${status}"`,
      user,
      saved.id,
    );
    const { photoBase64: _photo, ...rest } = saved;
    return rest;
  }

  async getComments(id: string, user?: AuthUser) {
    await this.findOne(id, user);
    return await this.commentRepo.find({ where: { reportId: id }, order: { createdAt: 'ASC' } });
  }

  async addComment(id: string, text: string, user: AuthUser) {
    const report = await this.findOne(id, user);
    const comment = this.commentRepo.create({
      reportId: id,
      authorName: user.name ?? user.email,
      authorRole: user.role,
      text: text.trim(),
    });
    const saved = await this.commentRepo.save(comment);
    await this.activity.log(
      'comentario',
      `Comentario en el reporte de ${report.species}: "${saved.text.slice(0, 80)}"`,
      user,
      id,
    );
    return saved;
  }
}
