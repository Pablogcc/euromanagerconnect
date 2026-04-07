import '../hive/hive_servicio.dart';
import 'db_config.dart';

// Almacen de configuracion con persistencia en Hive.
class DbConfigStore {
  static const String _key = 'db_config';
  static DbConfig? current;

  // Carga la configuracion desde Hive si existe.
  static Future<void> load() async {
    await HiveService.ensureBoxOpen();
    final map = HiveService.box.get(_key);
    if (map is Map) {
      current = DbConfig.fromMap(map);
    }
  }

  // Guarda la configuracion en Hive.
  static Future<void> save(DbConfig config) async {
    await HiveService.ensureBoxOpen();
    current = config;
    await HiveService.box.put(_key, config.toMap());
  }

  // Elimina la configuracion guardada.
  static Future<void> clear() async {
    await HiveService.ensureBoxOpen();
    current = null;
    await HiveService.box.delete(_key);
  }
}
