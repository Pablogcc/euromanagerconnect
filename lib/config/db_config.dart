
// Configuracion de conexion a SQL Server.
// Esta clase NO conecta por si misma: solo guarda los datos
// y construye la connection string que usara el cliente ODBC.
class DbConfig {
  DbConfig({
    required this.server,
    required this.instance,
    this.port,
    required this.database,
    this.username,
    this.password,
    required this.trustedConnection,
    required this.encrypt,
    required this.trustServerCertificate,
  });

  // Nombre del servidor o maquina (ej: DESKTOP-33C5SMD).
  final String server;
  // Nombre de la instancia de SQL Server (ej: SQLEXPRESS).
  final String instance;
  // Puerto opcional. Si es null, se conecta sin puerto fijo.
  final int? port;
  // Nombre de la base de datos.
  final String database;
  // Usuario para SQL Auth (opcional si se usa Trusted Connection).
  final String? username;
  // Password para SQL Auth (opcional si se usa Trusted Connection).
  final String? password;
  // Autenticacion de Windows (Trusted_Connection).
  final bool trustedConnection;
  // Si true, activa TLS (encrypt) en la conexion.
  final bool encrypt;
  // Si true, acepta el certificado del servidor (para entornos locales).
  final bool trustServerCertificate;

  // Construye el valor del SERVER.
  // Ejemplo sin puerto:   DESKTOP-33C5SMD\SQLEXPRESS
  // Ejemplo con puerto:   DESKTOP-33C5SMD\SQLEXPRESS,1433
  String get serverWithInstance {
    final base = '$server\\$instance';
    if (port == null) return base;
    return '$base,$port';
  }

  // Construye la connection string final para ODBC Driver 18.
  // Esta cadena es la que usara el cliente para conectarse.
  String get connectionString {
    // ODBC no entiende true/false, solo entiende Yes/No.
    // Por eso convertimos los booleanos a texto.
    final encryptValue = encrypt ? 'Yes' : 'No';
    final trustCert = trustServerCertificate ? 'Yes' : 'No';

    // "Trusted_Connection" significa "usar el usuario de Windows".
    // Si esta activado, NO se usa usuario/contraseña.
    // Si esta desactivado, se usa SQL Auth con UID/PWD.
    final authPart = trustedConnection
        ? 'Trusted_Connection=Yes;'
        : 'Trusted_Connection=No;UID=$username;PWD=$password;';

    return 'DRIVER={ODBC Driver 18 for SQL Server};'
        'SERVER=$serverWithInstance;'
        'DATABASE=$database;'
        '$authPart'
        'Encrypt=$encryptValue;'
        'TrustServerCertificate=$trustCert;';
  }

  // Convierte la configuracion a un Map para guardarla en Hive.
  Map<String, dynamic> toMap() {
    return {
      'server': server,
      'instance': instance,
      'port': port,
      'database': database,
      'username': username,
      'password': password,
      'trustedConnection': trustedConnection,
      'encrypt': encrypt,
      'trustServerCertificate': trustServerCertificate,
    };
  }

  // Reconstruye la configuracion desde un Map guardado en Hive.
  static DbConfig fromMap(Map<dynamic, dynamic> map) {
    return DbConfig(
      server: map['server'] as String,
      instance: map['instance'] as String,
      port: map['port'] as int?,
      database: map['database'] as String,
      username: map['username'] as String?,
      password: map['password'] as String?,
      trustedConnection: map['trustedConnection'] as bool,
      encrypt: map['encrypt'] as bool,
      trustServerCertificate: map['trustServerCertificate'] as bool,
    );
  }
}
