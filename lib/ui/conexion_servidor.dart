import 'package:flutter/material.dart';
import '../config/db_config.dart';
import '../config/db_almacen_configuracion.dart';
import '../data/sql/sql_cliente.dart';

// Pantalla de configuracion de SQL Server.
// Permite crear/editar/borrar la configuracion y probar la conexion.
class DbConfigPage extends StatefulWidget {
  const DbConfigPage({super.key});

  @override
  State<DbConfigPage> createState() => _DbConfigPageState();
}

class _DbConfigPageState extends State<DbConfigPage> {
  // Controladores para los campos de texto.
  final _serverCtrl = TextEditingController();
  final _instanceCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _dbCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // Flags de la conexion.
  bool _trusted = true;
  bool _encrypt = true;
  bool _trustCert = true;

  // Estado de la UI.
  bool _isBusy = false;
  String _status = 'Sin configurar';
  String _error = '';

  // Configuracion actual en memoria (no persistente aun).
  DbConfig? _current;

  @override
  void initState() {
    super.initState();
    // Si hay configuracion guardada, rellenamos el formulario.
    final saved = DbConfigStore.current;
    if (saved != null) {
      _current = saved;
      _serverCtrl.text = saved.server;
      _instanceCtrl.text = saved.instance;
      _portCtrl.text = saved.port?.toString() ?? '';
      _dbCtrl.text = saved.database;
      _userCtrl.text = saved.username ?? '';
      _passCtrl.text = saved.password ?? '';
      _trusted = saved.trustedConnection;
      _encrypt = saved.encrypt;
      _trustCert = saved.trustServerCertificate;
      _status = 'Configuracion cargada';
    }
  }

  // Crear o actualizar la configuracion y probar la conexion.
  Future<void> _createOrUpdate() async {
    setState(() {
      _isBusy = true;
      _status = 'Probando conexion...';
      _error = '';
    });

    // Puerto opcional: si esta vacio, se guarda como null.
    final portText = _portCtrl.text.trim();
    final port = portText.isEmpty ? null : int.tryParse(portText);

    // Construimos el objeto de configuracion con los datos del formulario.
    final config = DbConfig(
      server: _serverCtrl.text.trim(),
      instance: _instanceCtrl.text.trim(),
      port: port,
      database: _dbCtrl.text.trim(),
      username:
          _userCtrl.text.trim().isEmpty ? null : _userCtrl.text.trim(),
      password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
      trustedConnection: _trusted,
      encrypt: _encrypt,
      trustServerCertificate: _trustCert,
    );

    try {
      // Prueba real de conexion.
      await SqlCliente().testConnection(config);
      await DbConfigStore.save(config);
      setState(() {
        _current = config;
        _status = 'Conectado OK';
      });
    } catch (e) {
      // Error de conexion: se muestra el mensaje.
      setState(() {
        _status = 'ERROR';
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  // Elimina la configuracion (vuelve al estado inicial).
  Future<void> _resetConfig() async {
    _serverCtrl.clear();
    _instanceCtrl.clear();
    _portCtrl.clear();
    _dbCtrl.clear();
    _userCtrl.clear();
    _passCtrl.clear();
    _trusted = true;
    _encrypt = true;
    _trustCert = true;
    _current = null;
    await DbConfigStore.clear();
    _status = 'Sin configurar';
    _error = '';
    setState(() {});
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    _instanceCtrl.dispose();
    _portCtrl.dispose();
    _dbCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar SQL Server')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campos principales de conexion.
            TextField(
              controller: _serverCtrl,
              decoration: const InputDecoration(labelText: 'Servidor'),
            ),
            TextField(
              controller: _instanceCtrl,
              decoration: const InputDecoration(labelText: 'Instancia'),
            ),
            TextField(
              controller: _portCtrl,
              decoration: const InputDecoration(labelText: 'Puerto (opcional)'),
            ),
            TextField(
              controller: _dbCtrl,
              decoration: const InputDecoration(labelText: 'Base de datos'),
            ),
            TextField(
              controller: _userCtrl,
              decoration:
                  const InputDecoration(labelText: 'Usuario (SQL)'),
            ),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Contraseña (SQL)'),
            ),
            const SizedBox(height: 12),

            // Opciones de seguridad y autenticacion.
            SwitchListTile(
              title:
                  const Text('Usar usuario de Windows'),
              value: _trusted,
              onChanged: (v) => setState(() => _trusted = v),
            ),
            SwitchListTile(
              title: const Text('Cifrar conexión'),
              value: _encrypt,
              onChanged: (v) => setState(() => _encrypt = v),
            ),
            SwitchListTile(
              title: const Text('Confiar en certificado del servidor'),
              value: _trustCert,
              onChanged: (v) => setState(() => _trustCert = v),
            ),
            const SizedBox(height: 12),

            // Acciones principales.
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: _isBusy ? null : _createOrUpdate,
                  child: Text(_isBusy ? 'Probando...' : 'Guardar y probar'),
                ),
                OutlinedButton(
                  onPressed: _isBusy ? null : _resetConfig,
                  child: const Text('Eliminar / Resetear'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estado y mensajes.
            Text('Estado: $_status'),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText('Error: $_error'),
            ],
            if (_current != null) ...[
              const SizedBox(height: 8),
              const Text('Configuración guardada en memoria.'),
            ],
          ],
        ),
      ),
    );
  }
}
