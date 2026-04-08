import 'package:flutter/material.dart';
import '../config/db_almacen_configuracion.dart';
import '../config/web_almacen_configuracion.dart';
import '../config/constantes_ui.dart';

// Pantalla principal del conector (contenido).
// Muestra estado de conexion y estado tecnico basico.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sqlConfig = DbConfigStore.current;
    final webConfig = WebConfigStore.current;

    final estadoSql = sqlConfig == null ? 'Sin configurar' : 'Configurado';
    final estadoWeb = webConfig == null
        ? 'Sin configurar'
        : 'Configurado (${webConfig.conexiones.length} conexiones)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panel principal',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ConstantesUI.colorPrimario,
              ),
        ),
        const SizedBox(height: ConstantesUI.espacioGrande),
        _EstadoItem(titulo: 'SQL Server', valor: estadoSql),
        _EstadoItem(titulo: 'Conexión web', valor: estadoWeb),
        const SizedBox(height: ConstantesUI.espacioGrande),
        const Text('Logs (pendiente)'),
      ],
    );
  }
}

class _EstadoItem extends StatelessWidget {
  const _EstadoItem({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ConstantesUI.espacio),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(valor),
        ],
      ),
    );
  }
}
