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

  it('un Ciudadano NO puede cambiar el estado (403)', () => {
    expect(() =>
      controller.updateStatus(id, { status: 'Resuelto' }, { user: { role: 'Ciudadano' } }),
    ).toThrow(ForbiddenException);
    expect(service.updateStatus).not.toHaveBeenCalled();
  });

  it('un Albergue sí puede cambiar el estado', () => {
    const r = controller.updateStatus(id, { status: 'Resuelto' }, { user: { role: 'Albergue' } });
    expect(service.updateStatus).toHaveBeenCalledWith(id, 'Resuelto');
    expect(r).toEqual({ id: '1', status: 'Resuelto' });
  });
});
