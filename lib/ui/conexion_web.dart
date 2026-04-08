import 'package:flutter/material.dart';
import '../config/web_config.dart';
import '../config/web_almacen_configuracion.dart';
import '../data/web/web_cliente.dart';

// Pantalla de conexion con el servidor web (Euromanager Web).
// Diseño inspirado en los ajustes web del otro proyecto.
class ConexionWebPage extends StatefulWidget {
  const ConexionWebPage({super.key});

  @override
  State<ConexionWebPage> createState() => _ConexionWebPageState();
}

class _ConexionWebPageState extends State<ConexionWebPage> {
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
      _estado = 'Probando conexión...';
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
    const Color primario = Color.fromRGBO(83, 77, 100, 1);
    const Color secundario = Color.fromARGB(255, 201, 11, 173);
    const LinearGradient fondo = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 227, 181, 226),
        Color.fromARGB(255, 55, 54, 126),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: fondo),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ajustes - Conexión Web',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primario,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _urlCtrl,
                          decoration: const InputDecoration(
                            labelText: 'URL del servidor',
                            hintText: 'https://miempresa.com',
                          ),
                        ),
                        TextField(
                          controller: _proyectoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Proyecto',
                            hintText: 'euromanager',
                          ),
                        ),
                        TextField(
                          controller: _usuarioCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                          ),
                        ),
                        TextField(
                          controller: _contrasenaCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secundario,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _isBusy ? null : _guardarYProbar,
                              child: Text(
                                _isBusy
                                    ? 'Probando...'
                                    : 'Guardar y probar',
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primario,
                              ),
                              onPressed: _isBusy ? null : _reset,
                              child: const Text('Eliminar / Resetear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Estado: $_estado'),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          SelectableText('Error: $_error'),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
