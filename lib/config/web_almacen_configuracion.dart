import '../hive/hive_servicio.dart';
import 'web_config.dart';

// Almacen de configuracion web con persistencia en Hive.
class WebConfigStore {
  static const String _key = 'web_config';
  static WebConfig? current;

  // Carga la configuracion desde Hive si existe.
  static Future<void> load() async {
    await HiveService.ensureBoxOpen();
    final map = HiveService.box.get(_key);
    if (map is Map) {
      current = WebConfig.fromMap(map);
    }
  }

  // Guarda la configuracion en Hive.
  static Future<void> save(WebConfig config) async {
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
