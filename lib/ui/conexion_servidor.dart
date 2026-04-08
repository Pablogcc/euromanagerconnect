import 'package:flutter/material.dart';
import '../config/constantes_ui.dart';
import '../config/db_config.dart';
import '../config/db_almacen_configuracion.dart';
import '../config/web_config.dart';
import '../config/web_almacen_configuracion.dart';
import '../data/sql/sql_cliente.dart';
import '../data/web/web_cliente.dart';

// Pantalla de ajustes de conexiones (SQL Server y Web) en pestañas.
// Estilo inspirado en los ajustes web del otro proyecto.
class DbConfigPage extends StatefulWidget {
  const DbConfigPage({super.key});

  @override
  State<DbConfigPage> createState() => _DbConfigPageState();
}

class _DbConfigPageState extends State<DbConfigPage> {
  @override
  Widget build(BuildContext context) {
    const Color primario = ConstantesUI.colorPrimario;
    const Color secundario = ConstantesUI.colorSecundario;

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajustes - Conexiones',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primario,
                ),
          ),
          const SizedBox(height: ConstantesUI.espacio),
          TabBar(
            labelColor: primario,
            unselectedLabelColor: Colors.black54,
            indicatorColor: secundario,
            tabs: const [
              Tab(text: 'SQL Server'),
              Tab(text: 'Conexión web'),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Expanded(
            child: TabBarView(
              children: [
                _SqlConfigForm(primario: primario),
                _WebConfigForm(primario: primario, secundario: secundario),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Formulario de configuracion SQL Server.
class _SqlConfigForm extends StatefulWidget {
  const _SqlConfigForm({required this.primario});
  final Color primario;

  @override
  State<_SqlConfigForm> createState() => _SqlConfigFormState();
}

class _SqlConfigFormState extends State<_SqlConfigForm> {
  final _serverCtrl = TextEditingController();
  final _instanceCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  final _dbCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _trusted = true;
  bool _encrypt = true;
  bool _trustCert = true;

  bool _isBusy = false;
  String _status = 'Sin configurar';
  String _error = '';
  DbConfig? _current;

  @override
  void initState() {
    super.initState();
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
      _status = 'Configuración cargada';
    }
  }

  Future<void> _createOrUpdate() async {
    setState(() {
      _isBusy = true;
      _status = 'Guardando y comprobando...';
      _error = '';
    });

    final portText = _portCtrl.text.trim();
    final port = portText.isEmpty ? null : int.tryParse(portText);

    final config = DbConfig(
      server: _serverCtrl.text.trim(),
      instance: _instanceCtrl.text.trim(),
      port: port,
      database: _dbCtrl.text.trim(),
      username: _userCtrl.text.trim().isEmpty ? null : _userCtrl.text.trim(),
      password: _passCtrl.text.isEmpty ? null : _passCtrl.text,
      trustedConnection: _trusted,
      encrypt: _encrypt,
      trustServerCertificate: _trustCert,
    );

    try {
      await SqlCliente().testConnection(config);
      await DbConfigStore.save(config);
      setState(() {
        _current = config;
        _status = 'Conectado OK';
      });
    } catch (e) {
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conexión SQL Server',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.primario,
                ),
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Wrap(
            spacing: ConstantesUI.espacio,
            runSpacing: ConstantesUI.espacio,
            children: [
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _serverCtrl,
                  decoration: const InputDecoration(labelText: 'Servidor'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _instanceCtrl,
                  decoration: const InputDecoration(labelText: 'Instancia'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _portCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Puerto (opcional)'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _dbCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Base de datos'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _userCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Usuario (SQL)'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Contraseña (SQL)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacio),
          SwitchListTile(
            title: const Text('Usar usuario de Windows'),
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
          const SizedBox(height: ConstantesUI.espacio),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: _isBusy ? null : _createOrUpdate,
                child: Text(_isBusy ? 'Guardando...' : 'Guardar'),
              ),
              OutlinedButton(
                onPressed: _isBusy ? null : _resetConfig,
                child: const Text('Eliminar / Resetear'),
              ),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacioGrande),
          Text('Estado: $_status'),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: ConstantesUI.espacio),
            SelectableText('Error: $_error'),
          ],
          if (_current != null) ...[
            const SizedBox(height: ConstantesUI.espacio),
            const Text('Configuración guardada en memoria.'),
          ],
        ],
      ),
    );
  }
}

// Formulario de configuracion de conexion web.
class _WebConfigForm extends StatefulWidget {
  const _WebConfigForm({required this.primario, required this.secundario});
  final Color primario;
  final Color secundario;

  @override
  State<_WebConfigForm> createState() => _WebConfigFormState();
}

class _WebConfigFormState extends State<_WebConfigForm> {
  final _urlCtrl = TextEditingController();
  final _proyectoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  bool _isBusy = false;
  String _estado = 'Sin configurar';
  String _error = '';

  @override
  void initState() {
    super.initState();
    final saved = WebConfigStore.current;
    if (saved != null) {
      _urlCtrl.text = saved.url;
      _proyectoCtrl.text = saved.proyecto;
      _usuarioCtrl.text = saved.usuario ?? '';
      _contrasenaCtrl.text = saved.contrasena ?? '';
      _estado = 'Configuración cargada';
    }
  }

  Future<void> _guardarYProbar() async {
    setState(() {
      _isBusy = true;
      _estado = 'Guardando y comprobando...';
      _error = '';
    });

    final config = WebConfig(
      url: _urlCtrl.text.trim(),
      proyecto: _proyectoCtrl.text.trim(),
      usuario: _usuarioCtrl.text.trim().isEmpty ? null : _usuarioCtrl.text.trim(),
      contrasena: _contrasenaCtrl.text.isEmpty ? null : _contrasenaCtrl.text,
    );

    try {
      await WebCliente().testConnection(config);
      await WebConfigStore.save(config);
      setState(() {
        _estado = 'Conectado OK';
      });
    } catch (e) {
      setState(() {
        _estado = 'ERROR';
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isBusy = false;
      });
    }
  }

  Future<void> _reset() async {
    _urlCtrl.clear();
    _proyectoCtrl.clear();
    _usuarioCtrl.clear();
    _contrasenaCtrl.clear();
    await WebConfigStore.clear();
    setState(() {
      _estado = 'Sin configurar';
      _error = '';
    });
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _proyectoCtrl.dispose();
    _usuarioCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conexión Web',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.primario,
                ),
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Wrap(
            spacing: ConstantesUI.espacio,
            runSpacing: ConstantesUI.espacio,
            children: [
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL del servidor',
                    hintText: 'https://miempresa.com',
                  ),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _proyectoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Proyecto',
                    hintText: 'euromanager',
                  ),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _usuarioCtrl,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _contrasenaCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Contraseña'),
                ),
              ),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.secundario,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isBusy ? null : _guardarYProbar,
                child: Text(_isBusy ? 'Guardando...' : 'Guardar'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.primario,
                ),
                onPressed: _isBusy ? null : _reset,
                child: const Text('Eliminar / Resetear'),
              ),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacioGrande),
          Text('Estado: $_estado'),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: ConstantesUI.espacio),
            SelectableText('Error: $_error'),
          ],
        ],
      ),
    );
  }
}
