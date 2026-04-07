import 'package:flutter/material.dart';
import '../data/sql/sql_cliente.dart';
import '../config/db_almacen_configuracion.dart';
import 'conexion_servidor.dart';

// Pantalla principal del conector.
// Muestra el estado de conexion y da acceso a la pantalla de ajustes.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isBusy = false;
  String _status = 'Sin configurar';
  String _error = '';

  // Prueba la conexion usando la configuracion guardada en memoria.
  Future<void> _testConnection() async {
    final config = DbConfigStore.current;
    if (config == null) {
      setState(() {
        _status = 'Sin configurar';
        _error = '';
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _status = 'Probando conexion...';
      _error = '';
    });

    try {
      await SqlCliente().testConnection(config);
      setState(() => _status = 'Conectado OK');
    } catch (e) {
      setState(() {
        _status = 'ERROR';
        _error = e.toString();
      });
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conector - Principal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: $_status'),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText('Error: $_error'),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _isBusy ? null : _testConnection,
                  child: Text(_isBusy ? 'Probando...' : 'Probar conexion'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DbConfigPage()),
                    );
                  },
                  child: const Text('Ajustes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
