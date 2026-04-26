import 'package:flutter/material.dart';
import 'package:prueba_proyecto/screens/main_menu.dart';
import 'package:prueba_proyecto/screens/main_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainApp', // Titulo de la aplicación
      debugShowCheckedModeBanner: false, // Con esto, oculto la etiqueta "debug" de la esquina
      theme: ThemeData( // Con esto, defino el tema que tendrá la aplicación
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4DB6AC),
            brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),

      initialRoute: '/', // Defino la pantalla que mostrará cuando se abra la aplicación
      routes: {
        '/': (context) => const LoginPage(), // Ruta a la pagina de Login
        '/home': (context) => const HomePage(), // Ruta a la página principal
      },
    );
  }
}

