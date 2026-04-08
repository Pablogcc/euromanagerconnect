import 'dart:io';

import 'package:flutter/material.dart';
import '../config/constantes_ui.dart';
import 'main_screen.dart';
import 'conexion_servidor.dart';

// Pantalla principal con menu lateral a la izquierda.
// El estilo sigue el sidebar del proyecto web (fondo morado, items con hover y seleccionado).
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
          // Sidebar
          Material(
            color: ConstantesUI.colorPrimario,
            child: SizedBox(
              width: 240,
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
                const SizedBox(height: 16),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: ListView(
                      children: [
                        _SidebarItem(
                          icono: Icons.home,
                          titulo: 'Principal',
                          seleccionado: _indice == 0,
                          onTap: () => setState(() => _indice = 0),
                        ),
                        _SidebarItem(
                          icono: Icons.settings,
                          titulo: 'Ajustes',
                          seleccionado: _indice == 1,
                          onTap: () => setState(() => _indice = 1),
                        ),
                      ],
                    ),
                  ),
                ),
                _SidebarItem(
                  icono: Icons.exit_to_app,
                  titulo: 'Salir',
                  seleccionado: false,
                  onTap: _salir,
                ),
                const SizedBox(height: 16),
              ],
              ),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
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
    return ListTile(
      hoverColor: ConstantesUI.colorSecundario.withOpacity(0.8),
      selectedTileColor: ConstantesUI.colorSecundario,
      selected: seleccionado,
      leading: Icon(icono, color: Colors.white, size: 20),
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}
