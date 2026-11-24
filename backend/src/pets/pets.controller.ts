import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { PetsService } from './pets.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthUser, requireRole } from '../auth/auth-user';
import { CreatePetDto } from './dto/create-pet.dto';
import { AdoptPetDto } from './dto/adopt-pet.dto';
import { DecideRequestDto } from './dto/decide-request.dto';

type Request = { user: AuthUser };

@UseGuards(JwtAuthGuard)
@Controller('pets')
export class PetsController {
  constructor(private readonly pets: PetsService) {}

  /** Tablero de adopciones: solo mascotas disponibles. */
  @Get()
  listAvailable() {
    return this.pets.listAvailable();
  }

  /** Albergue: todas las mascotas (con adoptante). */
  @Get('manage/all')
  listAll(@Req() req: Request) {
    requireRole(req.user, 'Albergue');
    return this.pets.listAll();
  }

  /** Ciudadano: sus solicitudes de adopción. */
  @Get('requests/mine')
  myRequests(@Req() req: Request) {
    requireRole(req.user, 'Ciudadano');
    return this.pets.myRequests(req.user);
  }

  /** Albergue: todas las solicitudes. */
  @Get('requests/all')
  allRequests(@Req() req: Request) {
    requireRole(req.user, 'Albergue');
    return this.pets.allRequests();
  }

  @Patch('requests/:id')
  decide(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() body: DecideRequestDto,
    @Req() req: Request,
  ) {
    requireRole(req.user, 'Albergue');
    return this.pets.decide(id, body.status, req.user);
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string, @Req() req: Request) {
    return this.pets.findOne(id, req.user);
  }

  @Post()
  create(@Body() body: CreatePetDto, @Req() req: Request) {
    requireRole(req.user, 'Albergue');
    return this.pets.create(body, req.user);
  }

  @Post(':id/adopt')
  adopt(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() body: AdoptPetDto,
    @Req() req: Request,
  ) {
    requireRole(req.user, 'Ciudadano');
    return this.pets.adopt(id, req.user, body);
  }
}
