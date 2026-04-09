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

  // Obtiene la lista de empresas desde la tabla Empresa (campo Empresa).
  Future<List<Map<String, dynamic>>> fetchEmpresas(DbConfig config) async {
    final odbc = DartOdbcBlockingClient();
    try {
      await odbc.connectWithConnectionString(config.connectionString);
      return await odbc.execute(
        'SELECT IdEmpresa, Empresa FROM Empresa ORDER BY Empresa',
      );
    } finally {
      try {
        await odbc.disconnect();
      } catch (_) {}
    }
  }

  // Trae cabecera + linea (JOIN) de albaranes del SQL Server del cliente.
  // Version minima para evitar problemas de memoria del driver.
  Future<List<Map<String, dynamic>>> fetchAlbventaJoin(
    DbConfig config, {
    int limit = 10,
  }) async {
    final odbc = DartOdbcBlockingClient();
    try {
      await odbc.connectWithConnectionString(config.connectionString);

      // SQL Server: usamos TOP para limitar.
      final sql = '''
SELECT TOP ($limit)
  a.[AlbId],
  a.[AlbSerie],
  a.[AlbEmpresa],
  a.[AlbNumero],
  CONVERT(VARCHAR(19), a.[AlbFecha], 120) AS AlbFecha,
  a.[AlbCliente],
  c.[Dirección] AS Direccion,
  c.[Ciudad] AS Localidad,
  c.[Provincia] AS Provincia,
  c.[Pais] AS Pais,
  c.[CódigoPostal] AS Cp,
  l.[LinId],
  l.[LinAlbId],
  l.[LinModelo],
  l.[LinDescripcion],
  l.[LinPares],
  l.[LinPrecio]
FROM [Albaranes] a
LEFT JOIN [AlbaranesLineas] l
  ON l.[LinAlbId] = a.[AlbId]
LEFT JOIN [Clientes] c
  ON c.[IdCliente] = a.[AlbCliente]
ORDER BY a.[AlbFecha] DESC, a.[AlbId] DESC
''';

      return await odbc.execute(sql);
    } finally {
      try {
        await odbc.disconnect();
      } catch (_) {}
    }
  }
}
