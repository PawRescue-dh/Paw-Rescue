import { Injectable } from '@nestjs/common';
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

    return await this.reportRepo.save(report);
  }

  async findAll() {
    return await this.reportRepo.find({
      order: { createdAt: 'DESC' },
    });
  }
}