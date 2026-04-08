import 'package:flutter/material.dart';
import '../config/db_almacen_configuracion.dart';
import 'conexion_web.dart';
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
      _estado = 'Probando conexiÃ³n...';
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
      appBar: AppBar(title: const Text('Conector - Panel TÃ©cnico')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado: $_estado'),
            Text('Ãšltima comprobaciÃ³n: $ultima'),
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
                  child: Text(_isBusy ? 'Probando...' : 'Probar conexiÃ³n'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DbConfigPage()),
                    );
                  },
                  child: const Text('Ajustes'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ConexionWebPage()),
                    );
                  },
                  child: const Text('Conexión web'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

