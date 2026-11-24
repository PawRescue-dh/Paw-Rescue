import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ReportsService } from './reports.service';
import { Report } from './report.entity';
import { ReportComment } from './report-comment.entity';
import { ActivityService } from '../activity/activity.service';
import { AuthUser } from '../auth/auth-user';

const citizen: AuthUser = { sub: 'u1', email: 'ana@pawrescue.com', role: 'Ciudadano', name: 'Ana' };
const shelter: AuthUser = { sub: 's1', email: 'carlos@pawrescue.com', role: 'Albergue', name: 'Carlos' };

describe('ReportsService', () => {
  let service: ReportsService;
  const repo = {
    create: jest.fn((x) => x),
    save: jest.fn((x) => Promise.resolve({ id: 'uuid-1', status: 'Pendiente', species: 'Perro', urgency: 'Alta', ...x })),
    find: jest.fn(() => Promise.resolve([])),
    findOne: jest.fn(),
  };
  const comments = {
    create: jest.fn((x) => x),
    save: jest.fn((x) => Promise.resolve({ id: 'c1', ...x })),
    find: jest.fn(() => Promise.resolve([])),
  };
  const activity = { log: jest.fn() };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [
        ReportsService,
        { provide: getRepositoryToken(Report), useValue: repo },
        { provide: getRepositoryToken(ReportComment), useValue: comments },
        { provide: ActivityService, useValue: activity },
      ],
    }).compile();
    service = module.get(ReportsService);
  });

  it('create guarda un Point [longitud, latitud], al autor y registra la actividad', async () => {
    const result = await service.create(
      { species: 'Perro', urgency: 'Alta', description: 'Herido', latitude: 21.1561, longitude: -100.9312, photoBase64: 'AAAA' },
      citizen,
    );
    expect(repo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        reporterId: 'u1',
        reporterName: 'Ana',
        location: { type: 'Point', coordinates: [-100.9312, 21.1561] },
      }),
    );
    expect(result).not.toHaveProperty('photoBase64');
    expect(activity.log).toHaveBeenCalledWith('reporte', expect.any(String), citizen, 'uuid-1');
  });

  it('findAll (Albergue) no filtra por autor y no selecciona la foto', async () => {
    await service.findAll(shelter);
    const arg = (repo.find.mock.calls as any[][])[0][0];
    expect(arg.select.photoBase64).toBeUndefined();
    expect(arg.where).toEqual({});
    expect(arg.take).toBe(200);
  });

  it('findAll (Ciudadano) solo devuelve sus propios reportes', async () => {
    await service.findAll(citizen);
    const arg = (repo.find.mock.calls as any[][])[0][0];
    expect(arg.where).toEqual({ reporterId: 'u1' });
  });

  it('findOne lanza NotFoundException si no existe', async () => {
    repo.findOne.mockResolvedValueOnce(null);
    await expect(service.findOne('x', shelter)).rejects.toBeInstanceOf(NotFoundException);
  });

  it('findOne niega el acceso a un ciudadano que no es el autor', async () => {
    repo.findOne.mockResolvedValueOnce({ id: 'r1', reporterId: 'otro' });
    await expect(service.findOne('r1', citizen)).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('findOne permite al autor y al Albergue', async () => {
    repo.findOne.mockResolvedValue({ id: 'r1', reporterId: 'u1' });
    await expect(service.findOne('r1', citizen)).resolves.toBeDefined();
    await expect(service.findOne('r1', shelter)).resolves.toBeDefined();
  });

  it('updateStatus cambia el estado, no devuelve la foto y registra actividad', async () => {
    repo.findOne.mockResolvedValueOnce({ id: 'uuid-1', status: 'Pendiente', species: 'Perro', urgency: 'Alta', photoBase64: 'AAAA' });
    const result = await service.updateStatus('uuid-1', 'Resuelto', shelter);
    expect(result.status).toBe('Resuelto');
    expect(result).not.toHaveProperty('photoBase64');
    expect(activity.log).toHaveBeenCalledWith('estado', expect.stringContaining('Resuelto'), shelter, 'uuid-1');
  });

  it('addComment guarda el autor y registra actividad', async () => {
    repo.findOne.mockResolvedValueOnce({ id: 'r1', reporterId: 'u1', species: 'Gato' });
    const c = await service.addComment('r1', '  Voy en camino  ', shelter);
    expect(c.text).toBe('Voy en camino');
    expect(c.authorRole).toBe('Albergue');
    expect(activity.log).toHaveBeenCalledWith('comentario', expect.any(String), shelter, 'r1');
  });
});
