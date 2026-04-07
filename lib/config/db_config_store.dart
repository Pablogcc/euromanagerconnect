import 'db_config.dart';

// Almacen temporal en memoria para la configuracion actual.
// Esto es intencionalmente simple: mas adelante se persistira en Hive.
class DbConfigStore {
  static DbConfig? current;
}
