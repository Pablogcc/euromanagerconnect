import 'package:flutter/material.dart';
import '../config/db_almacen_configuracion.dart';
import '../data/sql/sql_cliente.dart';
import 'conexion_servidor.dart';

// Pantalla principal tecnica del conector.
// Muestra estado de conexion y acciones basicas.
class PantallaPrincipalTecnica extends StatefulWidget {
  const PantallaPrincipalTecnica({super.key});

  @override
  State<PantallaPrincipalTecnica> createState() =>
      _PantallaPrincipalTecnicaState();
}

class _PantallaPrincipalTecnicaState extends State<PantallaPrincipalTecnica> {
  bool _isBusy = false;
  String _estado = 'Sin configurar';
  String _ultimoError = '';
  DateTime? _ultimaComprobacion;

  Future<void> _probarConexion() async {
    final config = DbConfigStore.current;
    if (config == null) {
      setState(() {
        _estado = 'Sin configurar';
        _ultimoError = '';
        _ultimaComprobacion = DateTime.now();
      });
      return;
    }

    setState(() {
      _isBusy = true;
      _estado = 'Probando conexión...';
      _ultimoError = '';
      _ultimaComprobacion = DateTime.now();
    });

    try {
      await SqlCliente().testConnection(config);
      setState(() {
        _estado = 'Conectado OK';
      });
    } catch (e) {
      setState(() {
        _estado = 'ERROR';
        _ultimoError = e.toString();
      });
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultima =
        _ultimaComprobacion == null ? 'Nunca' : _ultimaComprobacion.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Conector - Panel Técnico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: $_estado'),
            Text('Última comprobación: $ultima'),
            if (_ultimoError.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText('Error: $_ultimoError'),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _isBusy ? null : _probarConexion,
                  child: Text(_isBusy ? 'Probando...' : 'Probar conexión'),
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
