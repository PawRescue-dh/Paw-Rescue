import { ConflictException, ForbiddenException, NotFoundException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { PetsService } from './pets.service';
import { Pet } from './pet.entity';
import { AdoptionRequest } from './adoption-request.entity';
import { PetsController } from './pets.controller';
import { ActivityService } from '../activity/activity.service';
import { AuthUser } from '../auth/auth-user';

const citizen: AuthUser = { sub: 'u1', email: 'ana@pawrescue.com', role: 'Ciudadano', name: 'Ana' };
const shelter: AuthUser = { sub: 's1', email: 'carlos@pawrescue.com', role: 'Albergue', name: 'Carlos' };

describe('PetsService (adopciones)', () => {
  let service: PetsService;
  const petRepo = {
    create: jest.fn((x) => x),
    save: jest.fn((x) => Promise.resolve({ id: 'p1', ...x })),
    find: jest.fn(() => Promise.resolve([])),
    findOne: jest.fn(),
    count: jest.fn(() => Promise.resolve(0)),
  };
  const requestRepo = {
    create: jest.fn((x) => x),
    save: jest.fn((x) => Promise.resolve({ id: 'r1', ...x })),
    find: jest.fn(() => Promise.resolve([])),
    findOne: jest.fn(),
  };
  const activity = { log: jest.fn() };

  const available = () => ({ id: 'p1', name: 'Max', status: 'Disponible', adopterId: null });

  beforeEach(async () => {
    jest.clearAllMocks();
    const module = await Test.createTestingModule({
      providers: [
        PetsService,
        { provide: getRepositoryToken(Pet), useValue: petRepo },
        { provide: getRepositoryToken(AdoptionRequest), useValue: requestRepo },
        { provide: ActivityService, useValue: activity },
      ],
    }).compile();
    service = module.get(PetsService);
  });

  it('listAvailable solo pide mascotas Disponibles y oculta datos del adoptante', async () => {
    petRepo.find.mockResolvedValueOnce([{ id: 'p1', name: 'Max', adopterPhone: '123', adopterEmail: 'x@y.com' }] as never);
    const list = await service.listAvailable();
    expect((petRepo.find.mock.calls as any[][])[0][0].where).toEqual({ status: 'Disponible' });
    expect(list[0].adopterPhone).toBeUndefined();
    expect(list[0].adopterEmail).toBeUndefined();
  });

  it('create publica una mascota con los datos del albergue', async () => {
    const pet = await service.create(
      { name: ' Luna ', species: 'Gato', age: '1 año', sex: 'Hembra', size: 'Pequeño', description: 'Tranquila', health: 'Sana', shelterPhone: '4181234567' },
      shelter,
    );
    expect(pet.name).toBe('Luna');
    expect(pet.shelterName).toBe('Carlos');
    expect(pet.shelterPhone).toBe('4181234567');
    expect(pet.status).toBe('Disponible');
    expect(activity.log).toHaveBeenCalledWith('mascota', expect.stringContaining('Luna'), shelter, 'p1');
  });

  it('adopt reserva la mascota (sale del tablero) y guarda al adoptante', async () => {
    petRepo.findOne.mockResolvedValueOnce(available());
    const req = await service.adopt('p1', citizen, { phone: '4181112233', message: 'Tengo patio' });
    expect(req.status).toBe('Pendiente');
    const savedPet = (petRepo.save.mock.calls as any[][])[0][0];
    expect(savedPet.status).toBe('Reservada');
    expect(savedPet.adopterId).toBe('u1');
    expect(savedPet.adopterName).toBe('Ana');
    expect(activity.log).toHaveBeenCalledWith('adopcion', expect.stringContaining('Ana'), citizen, 'r1');
  });

  it('adopt rechaza si la mascota ya fue elegida (409)', async () => {
    petRepo.findOne.mockResolvedValueOnce({ ...available(), status: 'Reservada' });
    await expect(service.adopt('p1', citizen, { phone: '4181112233' })).rejects.toBeInstanceOf(ConflictException);
    expect(requestRepo.save).not.toHaveBeenCalled();
  });

  it('adopt falla si la mascota no existe', async () => {
    petRepo.findOne.mockResolvedValueOnce(null);
    await expect(service.adopt('x', citizen, { phone: '4181112233' })).rejects.toBeInstanceOf(NotFoundException);
  });

  it('decide Aprobada marca la mascota como Adoptada', async () => {
    requestRepo.findOne.mockResolvedValueOnce({ id: 'r1', petId: 'p1', status: 'Pendiente', citizenName: 'Ana' });
    petRepo.findOne.mockResolvedValueOnce({ ...available(), status: 'Reservada', adopterId: 'u1' });
    await service.decide('r1', 'Aprobada', shelter);
    const savedPet = (petRepo.save.mock.calls as any[][])[0][0];
    expect(savedPet.status).toBe('Adoptada');
    expect(savedPet.adoptedAt).toBeInstanceOf(Date);
  });

  it('decide Rechazada devuelve la mascota al tablero y limpia al adoptante', async () => {
    requestRepo.findOne.mockResolvedValueOnce({ id: 'r1', petId: 'p1', status: 'Pendiente', citizenName: 'Ana' });
    petRepo.findOne.mockResolvedValueOnce({ ...available(), status: 'Reservada', adopterId: 'u1', adopterName: 'Ana' });
    await service.decide('r1', 'Rechazada', shelter);
    const savedPet = (petRepo.save.mock.calls as any[][])[0][0];
    expect(savedPet.status).toBe('Disponible');
    expect(savedPet.adopterId).toBeNull();
    expect(savedPet.adopterName).toBeNull();
  });

  it('decide no permite resolver dos veces la misma solicitud', async () => {
    requestRepo.findOne.mockResolvedValueOnce({ id: 'r1', petId: 'p1', status: 'Aprobada' });
    await expect(service.decide('r1', 'Rechazada', shelter)).rejects.toBeInstanceOf(ConflictException);
  });

  it('findOne oculta teléfono/correo del adoptante a terceros, pero no al Albergue ni al adoptante', async () => {
    const pet = { id: 'p1', adopterId: 'u1', adopterPhone: '123', adopterEmail: 'a@b.com' };
    petRepo.findOne.mockResolvedValue(pet);
    const other: AuthUser = { sub: 'u9', email: 'z@z.com', role: 'Ciudadano' };
    expect(((await service.findOne('p1', other)) as any).adopterPhone).toBeUndefined();
    expect(((await service.findOne('p1', citizen)) as any).adopterPhone).toBe('123');
    expect(((await service.findOne('p1', shelter)) as any).adopterPhone).toBe('123');
  });

  it('seedDemo no hace nada si ya hay mascotas', async () => {
    petRepo.count.mockResolvedValueOnce(3);
    await service.seedDemo();
    expect(petRepo.save).not.toHaveBeenCalled();
  });
});

describe('PetsController (roles)', () => {
  const svc = { create: jest.fn(), adopt: jest.fn(), listAll: jest.fn(), decide: jest.fn(), myRequests: jest.fn(), allRequests: jest.fn() } as any;
  const controller = new PetsController(svc);
  const citizenReq = { user: citizen };
  const shelterReq = { user: shelter };

  it('solo el Albergue publica mascotas y ve el control', () => {
    expect(() => controller.create({} as any, citizenReq)).toThrow(ForbiddenException);
    expect(() => controller.listAll(citizenReq)).toThrow(ForbiddenException);
    expect(() => controller.allRequests(citizenReq)).toThrow(ForbiddenException);
    expect(() => controller.decide('id', { status: 'Aprobada' }, citizenReq)).toThrow(ForbiddenException);
    controller.listAll(shelterReq);
    expect(svc.listAll).toHaveBeenCalled();
  });

  it('solo el Ciudadano adopta y ve sus solicitudes', () => {
    expect(() => controller.adopt('id', { phone: '4181112233' }, shelterReq)).toThrow(ForbiddenException);
    expect(() => controller.myRequests(shelterReq)).toThrow(ForbiddenException);
    controller.adopt('id', { phone: '4181112233' }, citizenReq);
    expect(svc.adopt).toHaveBeenCalled();
  });
});
