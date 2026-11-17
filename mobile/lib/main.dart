library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'screens/login_screen.dart';

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
        Provider.value(value: 'PawRescue'),
      ],
      child: MaterialApp(
        title: 'PawRescue',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}