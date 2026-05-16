import 'package:flutter/material.dart';
import 'package:prueba_proyecto/api/train_api.dart';
import 'package:prueba_proyecto/screens/home_screen.dart';
import 'package:prueba_proyecto/screens/login_screen.dart';
import 'package:prueba_proyecto/screens/register_screen.dart';
import 'package:prueba_proyecto/state/workout_store.dart';
import 'package:prueba_proyecto/theme/app_theme.dart';

final TrainApi trainApi = TrainApi();
final WorkoutStore workoutStore = WorkoutStore(trainApi);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        '/': (context) => LoginPage(api: trainApi, store: workoutStore),
        '/register': (context) => RegisterPage(api: trainApi),
        '/home': (context) => HomePage(api: trainApi, store: workoutStore),
      },
    );
  }
}
