import 'package:flutter/material.dart';

class CreateWorkoutModal extends StatelessWidget {
  const CreateWorkoutModal({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonColor = Color(0xFF4DB6AC);

    return Dialog(
      backgroundColor: Colors.transparent, // Lo pongo transparente para usar mi propio contenedor redondeado
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none, // Esto es para que la X de cerrar pueda sobresalir del cuadro
        children: [
          // Caja principal del modal de creación
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: neonColor.withOpacity(0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // El cuadro solo ocupa lo que necesita su contenido
              children: [
                const SizedBox(height: 20),
                _customTextField("Fecha", neonColor),
                const SizedBox(height: 25),
                
                // Contenedor para agrupar los datos del bloque de ejercicio
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: neonColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      _customTextField("block name|", neonColor, small: true),
                      const SizedBox(height: 15),
                      // Con maxLines: 5 hacemos que sea un campo de texto más alto
                      _customTextField("block description...|", neonColor, small: true, maxLines: 5),
                      const SizedBox(height: 15),
                      // Botón 'confirm' estilo píldora
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: neonColor, width: 2),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("confirm", style: TextStyle(color: neonColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Botón 'add block' para cerrar el entrenamiento
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: neonColor, width: 2),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("add block", style: TextStyle(color: neonColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // La X de cerrar arriba a la izquierda, fuera del cuadro principal
          Positioned(
            top: -15,
            left: -15,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Esto cierra el diálogo
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  shape: BoxShape.circle,
                  border: Border.all(color: neonColor, width: 2),
                ),
                child: const Center(
                  child: Text("X", style: TextStyle(color: neonColor, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Otro método para los campos de texto, este permite cambiar el tamaño de la letra
  Widget _customTextField(String hint, Color color, {bool small = false, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: color.withOpacity(0.5), fontSize: small ? 14 : 16),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
