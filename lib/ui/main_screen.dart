import 'package:flutter/material.dart';
import '../config/db_almacen_configuracion.dart';
import '../config/web_almacen_configuracion.dart';
import '../config/constantes_ui.dart';
import '../data/sql/sql_cliente.dart';

// Pantalla principal del conector (contenido).
// Muestra estado de conexion y estado tecnico basico.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> _logs = [];

  Future<void> _probarJoin() async {
    final config = DbConfigStore.current;
    if (config == null) {
      setState(() {
        _logs.insert(0, 'SQL no configurado.');
      });
      return;
    }

    setState(() {
      _logs.insert(0, 'Lanzando SELECT JOIN...');
    });

    try {
      final rows = await SqlCliente().fetchAlbventaJoin(config, limit: 10);
      setState(() {
        _logs.insert(0, 'Filas recibidas: ${rows.length}');
        for (final row in rows) {
          _logs.insert(0, row.toString());
        }
      });
    } catch (e) {
      setState(() {
        _logs.insert(0, 'ERROR: $e');
      });
    }
  }

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
        _EstadoItem(titulo: 'Conexion web', valor: estadoWeb),
        const SizedBox(height: ConstantesUI.espacio),
        ElevatedButton(
          onPressed: _probarJoin,
          child: const Text('Probar SELECT JOIN'),
        ),
        const SizedBox(height: ConstantesUI.espacio),
        const Text('Logs:'),
        const SizedBox(height: ConstantesUI.espacioPequeno),
        Container(
          height: 240,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: ConstantesUI.colorPrimario.withOpacity(0.2),
            ),
          ),
          child: ListView(
            children: _logs.map((e) => Text(e)).toList(),
          ),
        ),
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
