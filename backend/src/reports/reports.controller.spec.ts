import { ForbiddenException } from '@nestjs/common';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';

describe('ReportsController', () => {
  const service = {
    create: jest.fn(),
    findAll: jest.fn(),
    findOne: jest.fn(),
    updateStatus: jest.fn(() => ({ id: '1', status: 'Resuelto' })),
  } as unknown as ReportsService;
  const controller = new ReportsController(service);
  const id = '3f2504e0-4f89-11d3-9a0c-0305e82c3301';
  const citizen = { user: { sub: 'u1', email: 'a@b.com', role: 'Ciudadano' as const } };
  const shelter = { user: { sub: 's1', email: 'c@d.com', role: 'Albergue' as const, name: 'Carlos' } };

  it('un Ciudadano NO puede cambiar el estado (403)', () => {
    expect(() => controller.updateStatus(id, { status: 'Resuelto' }, citizen)).toThrow(ForbiddenException);
    expect(service.updateStatus).not.toHaveBeenCalled();
  });

  it('un Albergue sí puede cambiar el estado', () => {
    const r = controller.updateStatus(id, { status: 'Resuelto' }, shelter);
    expect(service.updateStatus).toHaveBeenCalledWith(id, 'Resuelto', shelter.user);
    expect(r).toEqual({ id: '1', status: 'Resuelto' });
  });

  it('findAll pasa el usuario para filtrar por rol', () => {
    controller.findAll(citizen);
    expect(service.findAll).toHaveBeenCalledWith(citizen.user);
  });
});
