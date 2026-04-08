import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hive/hive_servicio.dart';
import 'config/db_almacen_configuracion.dart';
import 'config/web_almacen_configuracion.dart';
import 'ui/pantalla_con_menu.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  // Punto de entrada de la app del conector.
  // Inicializamos Flutter y Hive antes de arrancar la UI.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos el gestor de ventana (necesario para bandeja).
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    center: true,
    title: 'Euromanager Connect',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Inicializacion de Hive y configuraciones guardadas.
  await HiveService.init();
  await DbConfigStore.load();
  await WebConfigStore.load();

  // Inicializamos la bandeja del sistema.
  final trayHandler = _TrayHandler();
  await trayHandler.init();

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

// Gestiona el icono de la bandeja y evita cerrar la app al pulsar X.
class _TrayHandler with WindowListener, TrayListener {
  _TrayHandler();

  Future<void> init() async {
    // Evita que el cierre mate la app, la ocultamos a bandeja.
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);

    // Configuramos el icono y el menu de la bandeja.
    trayManager.addListener(this);
    final trayPath = await _resolverIconoTray();
    await trayManager.setIcon(trayPath);
    await trayManager.setToolTip('Euromanager Connect');

    final menu = Menu(
      items: [
        MenuItem(key: 'mostrar', label: 'Mostrar'),
        MenuItem.separator(),
        MenuItem(key: 'salir', label: 'Salir'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void onWindowClose() async {
    await windowManager.hide();
  }

  @override
  void onTrayIconMouseDown() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem item) async {
    if (item.key == 'mostrar') {
      await windowManager.show();
      await windowManager.focus();
    }
    if (item.key == 'salir') {
      await windowManager.setPreventClose(false);
      await trayManager.destroy();
      await windowManager.close();
    }
  }
}

// Carga el icono de assets y lo escribe en un archivo temporal.
// En debug, no hay ejecutable final, asi que usamos assets.
Future<String> _resolverIconoTray() async {
  const assetPath = 'assets/tray.ico';
  final data = await rootBundle.load(assetPath);
  final bytes = data.buffer.asUint8List();

  final tempDir = Directory.systemTemp.createTempSync('euromanager_tray_');
  final file = File('${tempDir.path}${Platform.pathSeparator}tray.ico');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
