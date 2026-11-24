import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CreateReportDto } from './dto/create-report.dto';
import { UpdateStatusDto } from './dto/update-status.dto';

@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  create(@Body() body: CreateReportDto) {
    return this.reportsService.create(body);
  }

  /** Listado ligero: no incluye la foto (usar GET /reports/:id). */
  @Get()
  findAll() {
    return this.reportsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string) {
    return this.reportsService.findOne(id);
  }

  /** Solo los usuarios con rol Albergue pueden cambiar el estado. */
  @Patch(':id/status')
  updateStatus(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() body: UpdateStatusDto,
    @Req() req: { user?: { role?: string } },
  ) {
    if (req.user?.role !== 'Albergue') {
      throw new ForbiddenException('Solo un Albergue puede cambiar el estado');
    }
    return this.reportsService.updateStatus(id, body.status);
  }
}
