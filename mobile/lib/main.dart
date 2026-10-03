/// Autores: AGUSTIN PARRA y CARLOS PALMA
/// 
/// Main entry point for the PawRescue application.
/// Initializes dependency injection and starts the Flutter app.
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

/// Configures dependency injection.
void setupDependencies() {
  // TODO: Register repositories, view models, and data sources here.
}

void main() {
  setupDependencies();
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dummy provider just to have a valid MultiProvider setup
        Provider.value(value: 'PawRescue'),
      ],
      child: MaterialApp(
        title: 'PawRescue',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Scaffold(
          body: Center(
            child: Text('PawRescue App'),
          ),
        ),
      ),
    );
  }
}
