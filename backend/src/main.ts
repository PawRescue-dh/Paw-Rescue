import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Configuración de Swagger / OpenAPI
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Paw-Rescue API')
    .setDescription(
      'Documentación interactiva de la API backend de Paw-Rescue: rescate animal, autenticación y albergues.',
    )
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'Authorization',
        description: 'Ingresa tu token JWT en el formato: Bearer <token>',
        in: 'header',
      },
      'jwt-auth',
    )
    .addTag('auth', 'Endpoints de autenticación y gestión de usuarios')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`Servidor escuchando en: http://localhost:${port}`);
  console.log(`Documentación Swagger disponible en: http://localhost:${port}/api/docs`);
}

void bootstrap();
