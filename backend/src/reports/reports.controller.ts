import {
  Body,
  Controller,
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
import { AuthUser, requireRole } from '../auth/auth-user';
import { CreateReportDto } from './dto/create-report.dto';
import { UpdateStatusDto } from './dto/update-status.dto';
import { CreateCommentDto } from './dto/create-comment.dto';

type Request = { user: AuthUser };

@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  create(@Body() body: CreateReportDto, @Req() req: Request) {
    return this.reportsService.create(body, req.user);
  }

  /** Albergue: todos. Ciudadano: solo los suyos. No incluye la foto. */
  @Get()
  findAll(@Req() req: Request) {
    return this.reportsService.findAll(req.user);
  }

  @Get(':id')
  findOne(@Param('id', new ParseUUIDPipe()) id: string, @Req() req: Request) {
    return this.reportsService.findOne(id, req.user);
  }

  /** Solo los usuarios con rol Albergue pueden cambiar el estado. */
  @Patch(':id/status')
  updateStatus(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() body: UpdateStatusDto,
    @Req() req: Request,
  ) {
    requireRole(req.user, 'Albergue');
    return this.reportsService.updateStatus(id, body.status, req.user);
  }

  @Get(':id/comments')
  comments(@Param('id', new ParseUUIDPipe()) id: string, @Req() req: Request) {
    return this.reportsService.getComments(id, req.user);
  }

  @Post(':id/comments')
  addComment(
    @Param('id', new ParseUUIDPipe()) id: string,
    @Body() body: CreateCommentDto,
    @Req() req: Request,
  ) {
    return this.reportsService.addComment(id, body.text, req.user);
  }
}
