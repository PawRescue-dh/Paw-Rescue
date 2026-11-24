import { ArgumentMetadata, BadRequestException, ValidationPipe } from '@nestjs/common';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { CreateReportDto } from '../reports/dto/create-report.dto';

const pipe = new ValidationPipe({ whitelist: true, transform: true });
const run = (value: unknown, metatype: new () => object) =>
  pipe.transform(value, { type: 'body', metatype } as ArgumentMetadata);

const validReport = {
  species: 'Gato',
  urgency: 'Crítica',
  description: 'Atropellado',
  latitude: 21.15,
  longitude: -100.93,
};

describe('Validación de entradas (seguridad)', () => {
  it('registro válido pasa', async () => {
    await expect(
      run({ name: 'Ana', email: 'ana@pawrescue.com', password: 'Password123!', role: 'Ciudadano' }, RegisterDto),
    ).resolves.toBeDefined();
  });

  it.each([
    ['correo inválido', { name: 'Ana', email: 'no-es-correo', password: 'Password123!', role: 'Ciudadano' }],
    ['contraseña corta', { name: 'Ana', email: 'a@b.com', password: '123', role: 'Ciudadano' }],
    ['rol inexistente', { name: 'Ana', email: 'a@b.com', password: 'Password123!', role: 'Admin' }],
  ])('registro rechaza %s', async (_n, body) => {
    await expect(run(body, RegisterDto)).rejects.toBeInstanceOf(BadRequestException);
  });

  it('registro rechaza teléfono inválido y acepta uno válido', async () => {
    const base = { name: 'Ana', email: 'a@b.com', password: 'Password123!', role: 'Ciudadano' };
    await expect(run({ ...base, phone: 'abc' }, RegisterDto)).rejects.toBeInstanceOf(BadRequestException);
    await expect(run({ ...base, phone: '418 123 4567', acceptedPrivacy: true }, RegisterDto)).resolves.toBeDefined();
  });

  it('login rechaza cuerpo vacío', async () => {
    await expect(run({}, LoginDto)).rejects.toBeInstanceOf(BadRequestException);
  });

  it('reporte válido pasa', async () => {
    await expect(run(validReport, CreateReportDto)).resolves.toBeDefined();
  });

  it.each([
    ['urgencia inválida', { ...validReport, urgency: 'Urgentísima' }],
    ['especie inválida', { ...validReport, species: 'Dragón' }],
    ['latitud fuera de rango', { ...validReport, latitude: 123 }],
    ['longitud fuera de rango', { ...validReport, longitude: -400 }],
    ['descripción vacía', { ...validReport, description: '' }],
    ['coordenadas como texto', { ...validReport, latitude: 'abc' }],
  ])('reporte rechaza %s', async (_n, body) => {
    await expect(run(body, CreateReportDto)).rejects.toBeInstanceOf(BadRequestException);
  });

  it('elimina campos no permitidos (whitelist)', async () => {
    const r: any = await run({ ...validReport, status: 'Resuelto', hack: true }, CreateReportDto);
    expect(r.status).toBeUndefined();
    expect(r.hack).toBeUndefined();
  });
});
