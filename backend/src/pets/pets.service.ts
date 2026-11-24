import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Pet, PET_STATUS } from './pet.entity';
import { AdoptionRequest } from './adoption-request.entity';
import { ActivityService } from '../activity/activity.service';
import { AuthUser } from '../auth/auth-user';
import { CreatePetDto } from './dto/create-pet.dto';

/** Quita los datos del adoptante (solo los ve el Albergue o el propio adoptante). */
function hidePrivate(pet: Pet): Omit<Pet, 'adopterPhone' | 'adopterEmail'> & {
  adopterPhone?: undefined;
  adopterEmail?: undefined;
} {
  return { ...pet, adopterPhone: undefined, adopterEmail: undefined };
}

@Injectable()
export class PetsService {
  constructor(
    @InjectRepository(Pet) private readonly petRepo: Repository<Pet>,
    @InjectRepository(AdoptionRequest) private readonly requestRepo: Repository<AdoptionRequest>,
    private readonly activity: ActivityService,
  ) {}

  /** Tablero público: solo las mascotas disponibles. */
  async listAvailable() {
    const pets = await this.petRepo.find({
      where: { status: PET_STATUS.Available },
      order: { createdAt: 'DESC' },
    });
    return pets.map((p) => ({ ...p, adopterId: undefined, adopterName: undefined, adopterPhone: undefined, adopterEmail: undefined }));
  }

  /** Albergue: todas las mascotas con los datos del adoptante. */
  async listAll() {
    return await this.petRepo.find({ order: { createdAt: 'DESC' } });
  }

  async findOne(id: string, user?: AuthUser) {
    const pet = await this.petRepo.findOne({ where: { id } });
    if (!pet) throw new NotFoundException('Mascota no encontrada');
    if (user?.role === 'Albergue' || (user && pet.adopterId === user.sub)) return pet;
    return hidePrivate(pet);
  }

  async create(dto: CreatePetDto, user: AuthUser, shelterPhoneFallback?: string) {
    const pet = this.petRepo.create({
      name: dto.name.trim(),
      species: dto.species,
      age: dto.age.trim(),
      sex: dto.sex,
      size: dto.size,
      description: dto.description.trim(),
      health: dto.health.trim(),
      photoBase64: dto.photoBase64 || null,
      shelterId: user.sub,
      shelterName: user.name ?? 'Albergue',
      shelterPhone: dto.shelterPhone ?? shelterPhoneFallback ?? 'Sin teléfono',
      status: PET_STATUS.Available,
    });
    const saved = await this.petRepo.save(pet);
    await this.activity.log('mascota', `Nueva mascota publicada para adopción: ${saved.name}`, user, saved.id);
    return saved;
  }

  /** El ciudadano elige una mascota: queda "Reservada" y sale del tablero. */
  async adopt(petId: string, citizen: AuthUser, data: { phone: string; message?: string }) {
    const pet = await this.petRepo.findOne({ where: { id: petId } });
    if (!pet) throw new NotFoundException('Mascota no encontrada');
    if (pet.status !== PET_STATUS.Available) {
      throw new ConflictException('Esta mascota ya fue elegida por otra persona');
    }

    const request = await this.requestRepo.save(
      this.requestRepo.create({
        petId: pet.id,
        citizenId: citizen.sub,
        citizenName: citizen.name ?? citizen.email,
        citizenEmail: citizen.email,
        citizenPhone: data.phone.trim(),
        message: data.message?.trim() || null,
        status: 'Pendiente',
      }),
    );

    pet.status = PET_STATUS.Reserved;
    pet.adopterId = citizen.sub;
    pet.adopterName = request.citizenName;
    pet.adopterPhone = request.citizenPhone;
    pet.adopterEmail = request.citizenEmail;
    await this.petRepo.save(pet);

    await this.activity.log(
      'adopcion',
      `${request.citizenName} solicitó adoptar a ${pet.name}`,
      citizen,
      request.id,
    );
    return request;
  }

  /** Albergue aprueba (mascota adoptada) o rechaza (vuelve al tablero). */
  async decide(requestId: string, status: 'Aprobada' | 'Rechazada', user: AuthUser) {
    const request = await this.requestRepo.findOne({ where: { id: requestId } });
    if (!request) throw new NotFoundException('Solicitud no encontrada');
    if (request.status !== 'Pendiente') {
      throw new ConflictException('La solicitud ya fue resuelta');
    }
    const pet = await this.petRepo.findOne({ where: { id: request.petId } });
    if (!pet) throw new NotFoundException('Mascota no encontrada');

    request.status = status;
    request.decidedAt = new Date();
    await this.requestRepo.save(request);

    if (status === 'Aprobada') {
      pet.status = PET_STATUS.Adopted;
      pet.adoptedAt = new Date();
    } else {
      pet.status = PET_STATUS.Available;
      pet.adopterId = null;
      pet.adopterName = null;
      pet.adopterPhone = null;
      pet.adopterEmail = null;
    }
    await this.petRepo.save(pet);

    await this.activity.log(
      'adopcion',
      status === 'Aprobada'
        ? `Adopción aprobada: ${pet.name} se va con ${request.citizenName}`
        : `Solicitud rechazada: ${pet.name} vuelve al tablero`,
      user,
      request.id,
    );
    return request;
  }

  private async withPets(requests: AdoptionRequest[]) {
    const ids = [...new Set(requests.map((r) => r.petId))];
    const pets = ids.length ? await this.petRepo.find({ where: { id: In(ids) } }) : [];
    const byId = new Map(pets.map((p) => [p.id, p]));
    return requests.map((r) => ({ ...r, pet: byId.get(r.petId) ?? null }));
  }

  async myRequests(citizen: AuthUser) {
    const requests = await this.requestRepo.find({
      where: { citizenId: citizen.sub },
      order: { createdAt: 'DESC' },
    });
    return await this.withPets(requests);
  }

  async allRequests() {
    const requests = await this.requestRepo.find({ order: { createdAt: 'DESC' }, take: 200 });
    return await this.withPets(requests);
  }

  /** Datos de ejemplo para demostración (solo si SEED_DEMO_DATA=true y no hay mascotas). */
  async seedDemo() {
    if ((await this.petRepo.count()) > 0) return;
    const base = {
      shelterId: null,
      shelterName: 'Albergue Huellas de Esperanza',
      shelterPhone: '4181234567',
      photoBase64: null,
    };
    const demo = [
      { name: 'Max', species: 'Perro', age: '2 años', sex: 'Macho', size: 'Mediano', health: 'Sano y vacunado', description: 'Es un perrito muy cariñoso, juguetón y sociable. Busca una familia que le dé mucho amor.' },
      { name: 'Luna', species: 'Gato', age: '1 año', sex: 'Hembra', size: 'Pequeño', health: 'Esterilizada', description: 'Gatita tranquila que adora las siestas al sol y las caricias.' },
      { name: 'Rocky', species: 'Perro', age: '4 años', sex: 'Macho', size: 'Grande', health: 'En recuperación', description: 'Rescatado de la calle, ya está mucho mejor. Muy leal y protector.' },
      { name: 'Mishi', species: 'Gato', age: '6 meses', sex: 'Macho', size: 'Pequeño', health: 'Sano, desparasitado', description: 'Travieso y curioso, ideal para una casa con niños.' },
    ];
    await this.petRepo.save(demo.map((d) => this.petRepo.create({ ...base, ...d, status: PET_STATUS.Available })));
  }
}
