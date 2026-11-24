import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { ActivityService } from './activity.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthUser, requireRole } from '../auth/auth-user';

@UseGuards(JwtAuthGuard)
@Controller('activity')
export class ActivityController {
  constructor(private readonly activity: ActivityService) {}

  /** Solo el Albergue consulta el registro de acciones. */
  @Get()
  findRecent(@Req() req: { user: AuthUser }, @Query('limit') limit?: string) {
    requireRole(req.user, 'Albergue');
    const n = Number.parseInt(limit ?? '100', 10);
    return this.activity.findRecent(Number.isFinite(n) && n > 0 ? n : 100);
  }
}
