import 'package:flutter/material.dart';
import 'package:prueba_proyecto/screens/create_workout_modal.dart';

// Uso un StatefulWidget porque necesito que la pantalla cambie (botón abierto/cerrado)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Esta variable controla si se ve el botón de "Create workout" al pulsar los puntos
  bool _isExpanded = false;
  final Color neonColor = const Color(0xFF4DB6AC);

  // Función para lanzar el modal de creación de entrenos
  void _showCreateWorkoutModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8), // Oscurece el fondo al abrirlo
      builder: (context) => const CreateWorkoutModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // De momento la lista está vacía hasta que la conectemos más adelante
    final List<String> dias = []; 

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Bienvenido, Fernando",
          style: TextStyle(
            color: neonColor,
            decoration: TextDecoration.underline,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Iconos de perfil y ajustes arriba a la derecha
          Icon(Icons.person_outline, color: neonColor, size: 28),
          const SizedBox(width: 15),
          Icon(Icons.settings_outlined, color: neonColor, size: 28),
          const SizedBox(width: 20),
        ],
      ),
      body: ListView.builder(
        itemCount: dias.length,
        itemBuilder: (context, index) {
          // Aquí irá el diseño de las tarjetas cuando tengamos datos
          return Container(); 
        },
      ),
      // Botón flotante que se despliega hacia la izquierda
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Solo si _isExpanded es true dibujo el botón de "Create workout"
            if (_isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() => _isExpanded = false); // Lo cerramos al pulsar
                  _showCreateWorkoutModal(); // Abrimos el diálogo
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: neonColor, width: 2),
                    boxShadow: [
                      // Esto le da el efecto de brillo neón
                      BoxShadow(
                        color: neonColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Text(
                    "Create workout",
                    style: TextStyle(
                      color: neonColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            // El botón circular de los tres puntos que activa todo
            GestureDetector(
              onTap: () {
                // El setState le dice a Flutter que refresque la pantalla
                setState(() {
                  _isExpanded = !_isExpanded; 
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  shape: BoxShape.circle,
                  border: Border.all(color: neonColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: neonColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Icon(Icons.more_horiz, color: neonColor, size: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
