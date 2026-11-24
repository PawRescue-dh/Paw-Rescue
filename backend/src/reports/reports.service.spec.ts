import { NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ReportsService } from './reports.service';
import { Report } from './report.entity';

describe('ReportsService', () => {
  let service: ReportsService;
  const repo = {
    create: jest.fn((x) => x),
    save: jest.fn((x) => Promise.resolve({ id: 'uuid-1', status: 'Pendiente', ...x })),
    find: jest.fn(() => Promise.resolve([])),
    findOne: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [ReportsService, { provide: getRepositoryToken(Report), useValue: repo }],
    }).compile();
    service = module.get(ReportsService);
  });

  it('create guarda un Point con orden [longitud, latitud] y no devuelve la foto', async () => {
    const result = await service.create({
      species: 'Perro',
      urgency: 'Alta',
      description: 'Herido',
      latitude: 21.1561,
      longitude: -100.9312,
      photoBase64: 'AAAA',
    });
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        location: { type: 'Point', coordinates: [-100.9312, 21.1561] },
      }),
    );
    expect(result).not.toHaveProperty('photoBase64');
    expect(result.id).toBe('uuid-1');
  });

  it('findAll no selecciona la foto y limita resultados', async () => {
    await service.findAll();
    const arg = (repo.find.mock.calls as any[][])[0][0];
    expect(arg.select.photoBase64).toBeUndefined();
    expect(arg.take).toBe(200);
    expect(arg.order).toEqual({ createdAt: 'DESC' });
  });

  it('findOne lanza NotFoundException si no existe', async () => {
    repo.findOne.mockResolvedValueOnce(null);
    await expect(service.findOne('x')).rejects.toBeInstanceOf(NotFoundException);
  });

  it('updateStatus cambia el estado', async () => {
    repo.findOne.mockResolvedValueOnce({ id: 'uuid-1', status: 'Pendiente', photoBase64: 'AAAA' });
    const result = await service.updateStatus('uuid-1', 'Resuelto');
    expect(result.status).toBe('Resuelto');
    expect(result).not.toHaveProperty('photoBase64');
  });
});
