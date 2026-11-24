import { ActivityService } from './activity.service';

describe('ActivityService', () => {
  it('log guarda actor y referencia, y no lanza si la BD falla', async () => {
    const repo: any = { create: jest.fn((x) => x), save: jest.fn(() => Promise.resolve()), find: jest.fn() };
    const service = new ActivityService(repo);
    await service.log('reporte', 'Nuevo reporte', { name: 'Ana', role: 'Ciudadano' }, 'r1');
    expect(repo.create).toHaveBeenCalledWith({ type: 'reporte', message: 'Nuevo reporte', actorName: 'Ana', actorRole: 'Ciudadano', refId: 'r1' });

    repo.save.mockRejectedValueOnce(new Error('db caida'));
    await expect(service.log('x', 'y')).resolves.toBeUndefined();
  });

  it('findRecent limita a 300 y ordena por fecha descendente', async () => {
    const repo: any = { find: jest.fn(() => Promise.resolve([])) };
    await new ActivityService(repo).findRecent(9999);
    expect(repo.find).toHaveBeenCalledWith({ order: { createdAt: 'DESC' }, take: 300 });
  });
});
