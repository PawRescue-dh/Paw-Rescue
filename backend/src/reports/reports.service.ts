import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from './report.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(Report)
    private readonly reportRepo: Repository<Report>,
  ) {}

  async create(data: {
    species: string;
    urgency: string;
    description: string;
    latitude: number;
    longitude: number;
    photoBase64?: string;
  }) {
    const report = this.reportRepo.create({
      species: data.species,
      urgency: data.urgency,
      description: data.description,
      latitude: data.latitude,
      longitude: data.longitude,
      photoBase64: data.photoBase64 || '',
      location: {
        type: 'Point',
        coordinates: [data.longitude, data.latitude],
      },
    });

    const saved = await this.reportRepo.save(report);
    // La respuesta no devuelve la foto para no reenviar el payload completo.
    const { photoBase64: _photo, ...rest } = saved;
    return rest;
  }

  /** Listado sin foto y limitado, para que el mapa cargue rápido. */
  async findAll(limit = 200) {
    return await this.reportRepo.find({
      select: {
        id: true,
        species: true,
        urgency: true,
        description: true,
        latitude: true,
        longitude: true,
        status: true,
        createdAt: true,
      },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async findOne(id: string) {
    const report = await this.reportRepo.findOne({ where: { id } });
    if (!report) throw new NotFoundException('Reporte no encontrado');
    return report;
  }

  async updateStatus(id: string, status: string) {
    const report = await this.findOne(id);
    report.status = status;
    const saved = await this.reportRepo.save(report);
    const { photoBase64: _photo, ...rest } = saved;
    return rest;
  }
}
