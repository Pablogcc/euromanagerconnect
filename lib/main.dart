import 'package:flutter/material.dart';
import 'hive/hive_servicio.dart';
import 'config/db_almacen_configuracion.dart';
import 'config/web_almacen_configuracion.dart';
import 'ui/pantalla_con_menu.dart';

Future<void> main() async {
  // Punto de entrada de la app del conector.
  // Inicializamos Flutter y Hive antes de arrancar la UI.
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await DbConfigStore.load();
  await WebConfigStore.load();
  runApp(const ConnectorApp());
}

class ConnectorApp extends StatelessWidget {
  const ConnectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Euromanager Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const PantallaConMenu(),
    );
  }
}
