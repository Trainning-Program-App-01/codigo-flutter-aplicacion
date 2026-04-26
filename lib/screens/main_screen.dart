import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variable para no tener que escribir el color verde todo el rato
    const Color neonColor = Color(0xFF4DB6AC); 

    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para que resalten los colores neón
      body: Center(
        child: SingleChildScrollView( 
          // El scroll es para que no de error si el teclado tapa los campos
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Este es el cuadrado donde iría el logo de la app
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: neonColor, width: 1),
                  ),
                ),
                const SizedBox(height: 50),
                
                // Texto de email y su campo
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("email", style: TextStyle(color: neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _customTextField("******@********* .com", neonColor),
                
                const SizedBox(height: 25),
                
                // Texto de password y su campo (con el obscureText para que no se vea)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("password", style: TextStyle(color: neonColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _customTextField("****************", neonColor, isPassword: true),
                
                const SizedBox(height: 40),

                // El botón de entrar que nos manda a la lista de entrenos
                ElevatedButton(
                  onPressed: () {
                    // Aquí navegamos a la ruta /home que definí en el main.dart
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: const StadiumBorder(side: BorderSide(color: neonColor, width: 2)),
                  ),
                  child: const Text("login", style: TextStyle(color: neonColor, fontSize: 18)),
                ),

                const SizedBox(height: 80),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[800]?.withOpacity(0.5),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                  ),
                  child: const Text("reset your password", style: TextStyle(color: neonColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Me he creado este método para configurar los TextField una sola vez y que todos queden iguales
  Widget _customTextField(String hint, Color color, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: color.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color, width: 3),
        ),
      ),
    );
  }
}
