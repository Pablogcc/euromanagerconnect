import 'package:dart_odbc/dart_odbc.dart';
import '../../config/db_config.dart';

// Cliente SQL encargado de abrir la conexion y hacer pruebas basicas.
// No conoce la UI: solo recibe configuracion y ejecuta la comprobacion.
class SqlCliente {
  // Prueba de conexion:
  // 1) conecta con la connection string
  // 2) ejecuta una consulta simple
  // 3) siempre desconecta
  Future<void> testConnection(DbConfig config) async {
    // Usamos modo blocking para evitar problemas del driver al leer filas.
    final odbc = DartOdbcBlockingClient();
    try {
      // Conectar usando la cadena generada por DbConfig.
      await odbc.connectWithConnectionString(config.connectionString);
      // Consulta minima para validar conexion real.
      await odbc.execute('SELECT 1');
    } finally {
      // Cerrar la conexion pase lo que pase.
      try {
        await odbc.disconnect();
      } catch (_) {}
    }
  }
}
