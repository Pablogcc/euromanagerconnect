import 'package:flutter/material.dart';
import 'package:dart_odbc/dart_odbc.dart';

void main() {
  // Punto de entrada de la app del conector.
  runApp(const ConnectorApp());
}

class ConnectorApp extends StatelessWidget {
  const ConnectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App minima: tema basico y pantalla principal de prueba de conexion.
    return MaterialApp(
      title: 'Euromanager Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const ConnectionTestPage(),
    );
  }
}

class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({super.key});

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  // Parametros fijos para la prueba de conexion (sin DSN).
  static const String _driver = 'ODBC Driver 18 for SQL Server';
  static const String _server = r'DESKTOP-33C5SMD\SQLEXPRESS';
  static const String _database = 'DatosAparadoSQL';
  static const String _connectionString =
      r'DRIVER={ODBC Driver 18 for SQL Server};'
      r'SERVER=DESKTOP-33C5SMD\SQLEXPRESS;'
      r'DATABASE=DatosAparadoSQL;'
      r'Trusted_Connection=Yes;'
      r'Encrypt=Yes;'
      r'TrustServerCertificate=Yes;';

  // Estado de la UI.
  bool _isBusy = false;
  String _status = 'Sin probar';
  String _lastError = '';
  DateTime? _lastAttempt;

  Future<void> _testConnection() async {
    // Evita doble clic mientras conecta.
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _status = 'Conectando...';
      _lastError = '';
      _lastAttempt = DateTime.now();
    });

    // Cliente ODBC para abrir/cerrar la conexion.
    final odbc = DartOdbc();
    try {
      // Conecta por connection string (sin DSN).
      await odbc.connectWithConnectionString(_connectionString);
      // Lectura directa con columnas pequenas (evita campos grandes).
      final rows = await odbc.execute(
        'SELECT COUNT(1) AS total FROM dbo.Albaranes',
      );
      final total = rows.isNotEmpty ? rows.first['total'] : 0;
      _status = 'OK (Albaranes: $total)';
    } catch (e) {
      _status = 'ERROR';
      _lastError = e.toString();
    } finally {
      // Cierra la conexion siempre, incluso si falla.
      try {
        await odbc.disconnect();
      } catch (_) {}
      // Actualiza la UI si el widget sigue montado.
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastAttemptText = _lastAttempt == null
        ? 'Nunca'
        : _lastAttempt!.toIso8601String();

    return Scaffold(
      appBar: AppBar(title: const Text('Conector - Prueba SQL Server')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informacion de conexion visible para ver que se esta probando.
            _InfoRow(label: 'Driver', value: _driver),
            _InfoRow(label: 'Servidor', value: _server),
            _InfoRow(label: 'Base de datos', value: _database),
            const _InfoRow(
              label: 'Autenticacion',
              value: 'Windows (Trusted_Connection)',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Boton para ejecutar la prueba.
                ElevatedButton(
                  onPressed: _isBusy ? null : _testConnection,
                  child: Text(_isBusy ? 'Conectando...' : 'Probar conexion'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Resultado de la prueba.
            _StatusRow(label: 'Estado', value: _status),
            _StatusRow(label: 'Ultimo intento', value: lastAttemptText),
            if (_lastError.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Error',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              SelectableText(_lastError),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
