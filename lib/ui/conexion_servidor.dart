import 'package:flutter/material.dart';
import '../config/constantes_ui.dart';
import '../config/db_config.dart';
import '../config/db_almacen_configuracion.dart';
import '../config/web_config.dart';
import '../config/web_almacen_configuracion.dart';
import '../data/sql/sql_cliente.dart';
import '../data/web/web_cliente.dart';

// Pantalla de ajustes de conexiones (SQL Server y Web) en pestanas.
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
            labelColor: secundario,
            unselectedLabelColor: Colors.black54,
            indicatorColor: secundario,
            tabs: const [
              Tab(text: 'SQL Server'),
              Tab(text: 'Conexion web'),
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
  bool _encrypt = true; // fijo: siempre true
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
      _encrypt = true;
      _trustCert = saved.trustServerCertificate;
      _status = 'Configuracion cargada';
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
            'Conexion SQL Server',
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
                  decoration: const InputDecoration(labelText: 'Base de datos'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Usuario (SQL)'),
                ),
              ),
              SizedBox(
                width: ConstantesUI.anchoCampo,
                child: TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Contrasena (SQL)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: ConstantesUI.espacio),
          SwitchListTile(
            title: const Text('Usar usuario de Windows'),
            value: _trusted,
            onChanged: (v) => setState(() => _trusted = v),
            activeColor: ConstantesUI.colorPrimario,
            activeTrackColor:
                ConstantesUI.colorPrimario.withOpacity(0.35),
          ),
          SwitchListTile(
            title: const Text('Confiar en certificado del servidor'),
            value: _trustCert,
            onChanged: (v) => setState(() => _trustCert = v),
            activeColor: ConstantesUI.colorPrimario,
            activeTrackColor:
                ConstantesUI.colorPrimario.withOpacity(0.35),
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: _isBusy ? null : _createOrUpdate,
                child: Text(_isBusy ? 'Guardando...' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantesUI.colorSecundario,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton(
                onPressed: _isBusy ? null : _resetConfig,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ConstantesUI.colorSecundario,
                  side: const BorderSide(color: ConstantesUI.colorSecundario),
                ),
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
            const Text('Configuracion guardada en memoria.'),
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
  // Lista de conexiones web guardadas.
  final List<WebEndpoint> _conexiones = [];

  bool _isBusy = false;
  String _estado = 'Sin configurar';
  String _error = '';

  @override
  void initState() {
    super.initState();
    final saved = WebConfigStore.current;
    if (saved != null) {
      _conexiones.addAll(saved.conexiones);
      _estado = 'Configuracion cargada';
    }
  }

  // Abre el dialogo para crear una conexion nueva.
  Future<void> _crearConexion() async {
    final nueva = await _mostrarDialogoConexion(context);
    if (nueva == null) {
      return;
    }
    setState(() {
      _conexiones.add(nueva);
    });
  }

  // Abre el dialogo para editar una conexion existente.
  Future<void> _editarConexion(int index) async {
    final actual = _conexiones[index];
    final editada = await _mostrarDialogoConexion(context, actual: actual);
    if (editada == null) {
      return;
    }
    setState(() {
      _conexiones[index] = editada;
    });
  }

  // Elimina una conexion de la lista (sin guardar aun).
  void _eliminarConexion(int index) {
    setState(() {
      _conexiones.removeAt(index);
    });
  }

  // Guarda todas las conexiones y las prueba antes de persistir.
  Future<void> _guardarYProbar() async {
    setState(() {
      _isBusy = true;
      _estado = 'Guardando y comprobando...';
      _error = '';
    });

    // Validacion minima: todas deben tener IdEmpresa, URL y Proyecto.
    for (final c in _conexiones) {
      if (c.idEmpresa == null ||
          c.empresa.trim().isEmpty ||
          c.url.trim().isEmpty ||
          c.proyecto.trim().isEmpty) {
        setState(() {
          _isBusy = false;
          _estado = 'ERROR';
          _error =
              'Todas las conexiones deben tener IdEmpresa, Empresa, URL y Proyecto.';
        });
        return;
      }
    }

    final config = WebConfig(conexiones: List<WebEndpoint>.from(_conexiones));

    try {
      // Probamos todas las conexiones antes de guardar.
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

  // Resetea todas las conexiones guardadas.
  Future<void> _reset() async {
    await WebConfigStore.clear();
    setState(() {
      _conexiones.clear();
      _estado = 'Sin configurar';
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conexion Web',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.primario,
                ),
          ),
          const SizedBox(height: ConstantesUI.espacio),
          Text(
            'Conexiones web (todas activas)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: ConstantesUI.espacioPequeno),
          if (_conexiones.isEmpty)
            const Text('No hay conexiones configuradas.'),
          if (_conexiones.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _conexiones.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = _conexiones[index];
                return ListTile(
                  title: Text(
                    item.empresa.isEmpty
                        ? 'Empresa sin nombre'
                        : '${item.idEmpresa ?? '-'} - ${item.empresa}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${item.url} | ${item.proyecto}'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        onPressed: () => _editarConexion(index),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        onPressed: () => _eliminarConexion(index),
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: ConstantesUI.espacioPequeno),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _crearConexion,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Nueva conexion'),
            ),
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
                  foregroundColor: ConstantesUI.colorSecundario,
                  side: const BorderSide(color: ConstantesUI.colorSecundario),
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

// Dialogo para crear o editar una conexion web.
Future<WebEndpoint?> _mostrarDialogoConexion(
  BuildContext context, {
  WebEndpoint? actual,
}) async {
  final urlCtrl = TextEditingController(text: actual?.url ?? '');
  final proyectoCtrl = TextEditingController(text: actual?.proyecto ?? '');
  final usuarioCtrl = TextEditingController(text: actual?.usuario ?? '');
  final contrasenaCtrl = TextEditingController(text: actual?.contrasena ?? '');

  // Cargamos la lista de empresas desde SQL (si hay conexion configurada).
  final empresas = await _cargarEmpresasDesdeSql();
  final empresaInicial = empresas.firstWhere(
    (e) => e.nombre == actual?.empresa && e.id == actual?.idEmpresa,
    orElse: () => empresas.isNotEmpty ? empresas.first : EmpresaOption.vacia(),
  );

  return showDialog<WebEndpoint>(
    context: context,
    builder: (context) {
      final estiloTitulo = Theme.of(context).textTheme.bodyLarge;
      final estiloAviso = Theme.of(context).textTheme.labelSmall;
      bool mostrarContrasena = false;
      EmpresaOption? empresaSeleccionada =
          empresaInicial.id == null ? null : empresaInicial;
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: ConstantesUI.colorPrimario.withOpacity(0.15)),
        ),
        title: Text(
          actual == null ? 'Nueva conexion' : 'Editar conexion',
          style: estiloTitulo?.copyWith(
            color: ConstantesUI.colorPrimario,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: ConstantesUI.anchoDialogCreacion,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rellena los datos de la conexion.'),
                    const SizedBox(height: ConstantesUI.espacio),
                    if (empresas.isEmpty)
                      const Text(
                        'No se pudieron cargar empresas desde SQL.',
                      ),
                    DropdownButtonFormField<EmpresaOption>(
                      value: empresaSeleccionada,
                      isExpanded: true,
                      items: empresas
                          .map(
                            (e) => DropdownMenuItem<EmpresaOption>(
                              value: e,
                              child: Text('${e.id} - ${e.nombre}'),
                            ),
                          )
                          .toList(),
                      onChanged: empresas.isEmpty
                          ? null
                          : (value) {
                              setLocalState(() {
                                empresaSeleccionada = value;
                              });
                            },
                      decoration: const InputDecoration(
                        labelText: 'Empresa',
                        hintText: 'Selecciona una empresa',
                      ),
                    ),
                    TextField(
                      controller: urlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL del servidor',
                        hintText: 'https://miempresa.com',
                      ),
                    ),
                    TextField(
                      controller: proyectoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Proyecto',
                        hintText: 'euromanager',
                      ),
                    ),
                    TextField(
                      controller: usuarioCtrl,
                      decoration: const InputDecoration(labelText: 'Usuario'),
                    ),
                    TextField(
                      controller: contrasenaCtrl,
                      obscureText: !mostrarContrasena,
                      decoration: InputDecoration(
                        labelText: 'Contrasena',
                        suffixIcon: IconButton(
                          tooltip: mostrarContrasena
                              ? 'Ocultar contrasena'
                              : 'Ver contrasena',
                          icon: Icon(
                            mostrarContrasena
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setLocalState(() {
                              mostrarContrasena = !mostrarContrasena;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: ConstantesUI.espacio),
                    Text(
                      'Empresa, URL y Proyecto son obligatorios.',
                      style: estiloAviso?.copyWith(
                        color: ConstantesUI.colorPrimario,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantesUI.colorSecundario,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(
                WebEndpoint(
                  idEmpresa: empresaSeleccionada?.id,
                  empresa: (empresaSeleccionada?.nombre ?? '').trim(),
                  url: urlCtrl.text.trim(),
                  proyecto: proyectoCtrl.text.trim(),
                  usuario: usuarioCtrl.text.trim().isEmpty
                      ? null
                      : usuarioCtrl.text.trim(),
                  contrasena: contrasenaCtrl.text.isEmpty
                      ? null
                      : contrasenaCtrl.text,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

// Carga las empresas desde la tabla Empresa (campo Empresa).
Future<List<EmpresaOption>> _cargarEmpresasDesdeSql() async {
  final config = DbConfigStore.current;
  if (config == null) {
    return [];
  }
  try {
    final rows = await SqlCliente().fetchEmpresas(config);
    final empresas = <EmpresaOption>[];
    for (final row in rows) {
      final idValue = row['IdEmpresa'];
      final nombreValue = row['Empresa'];
      final id = idValue is int ? idValue : int.tryParse('$idValue');
      if (id != null && nombreValue is String && nombreValue.trim().isNotEmpty) {
        empresas.add(EmpresaOption(id: id, nombre: nombreValue.trim()));
      }
    }
    return empresas;
  } catch (_) {
    return [];
  }
}

// Opcion de empresa para el dropdown.
class EmpresaOption {
  const EmpresaOption({required this.id, required this.nombre});

  final int? id;
  final String nombre;

  static EmpresaOption vacia() => const EmpresaOption(id: null, nombre: '');
}
