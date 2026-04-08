import 'dart:io';

import 'package:flutter/material.dart';
import '../config/constantes_ui.dart';
import 'main_screen.dart';
import 'conexion_servidor.dart';

// Pantalla principal con menu lateral a la izquierda.
class PantallaConMenu extends StatefulWidget {
  const PantallaConMenu({super.key});

  @override
  State<PantallaConMenu> createState() => _PantallaConMenuState();
}

class _PantallaConMenuState extends State<PantallaConMenu> {
  int _indice = 0;

  Future<void> _salir() async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('¿Quieres cerrar la aplicación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (salir == true) {
      exit(0);
    }
  }

  Widget _contenido() {
    switch (_indice) {
      case 0:
        return const MainScreen();
      case 1:
        return const DbConfigPage();
      default:
        return const MainScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Menu lateral
          Container(
            width: 220,
            color: ConstantesUI.colorPrimario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'CONECTOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _MenuItem(
                  icono: Icons.home,
                  titulo: 'Principal',
                  seleccionado: _indice == 0,
                  onTap: () => setState(() => _indice = 0),
                ),
                _MenuItem(
                  icono: Icons.settings,
                  titulo: 'Ajustes',
                  seleccionado: _indice == 1,
                  onTap: () => setState(() => _indice = 1),
                ),
                const Spacer(),
                _MenuItem(
                  icono: Icons.exit_to_app,
                  titulo: 'Salir',
                  seleccionado: false,
                  onTap: _salir,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Container(
              color: Colors.white,
              padding: ConstantesUI.paddingPantalla,
              child: _contenido(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icono,
    required this.titulo,
    required this.seleccionado,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: seleccionado ? ConstantesUI.colorSecundario : Colors.transparent,
        child: Row(
          children: [
            Icon(icono, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
