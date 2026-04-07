import 'package:hive_flutter/hive_flutter.dart';

// Servicio minimo para inicializar Hive y abrir la caja principal.
class HiveService {
  static const String _boxName = 'app';

  // Inicializa Hive en Flutter (usa la carpeta de documentos del sistema).
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // Asegura que la caja esta abierta (por si no se llamo a init).
  static Future<void> ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get box => Hive.box(_boxName);
}
