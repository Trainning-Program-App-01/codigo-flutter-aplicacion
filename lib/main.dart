import 'package:flutter/material.dart';
import 'package:prueba_proyecto/screens/home_screen.dart';
import 'package:prueba_proyecto/screens/login_screen.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

final WorkoutStore workoutStore = WorkoutStore();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.neon,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => HomePage(store: workoutStore),
      },
    );
  }
}
