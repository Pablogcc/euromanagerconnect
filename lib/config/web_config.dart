class WebEndpoint {
  WebEndpoint({
    required this.idEmpresa,
    required this.empresa,
    required this.url,
    required this.proyecto,
    this.usuario,
    this.contrasena,
  });

  // Id interno de empresa en SQL Server.
  final int? idEmpresa;
  // Nombre visible de la empresa asociada a esta conexion.
  final String empresa;
  // URL base del servidor web (ej: https://miempresa.com).
  // Aqui no va el endpoint concreto, solo la base.
  final String url;
  // Nombre del proyecto/entorno en el servidor (especifico de esta URL).
  final String proyecto;
  // Usuario opcional para autenticar en el servicio web (por cada URL).
  final String? usuario;
  // Contrasena opcional para autenticar en el servicio web (por cada URL).
  final String? contrasena;

  Map<String, dynamic> toMap() {
    return {
      'idEmpresa': idEmpresa,
      'empresa': empresa,
      'url': url,
      'proyecto': proyecto,
      'usuario': usuario,
      'contrasena': contrasena,
    };
  }

  static WebEndpoint fromMap(Map<dynamic, dynamic> map) {
    return WebEndpoint(
      idEmpresa: map['idEmpresa'] as int?,
      empresa: map['empresa'] as String? ?? '',
      url: map['url'] as String,
      proyecto: map['proyecto'] as String,
      usuario: map['usuario'] as String?,
      contrasena: map['contrasena'] as String?,
    );
  }
}

class WebConfig {
  WebConfig({
    required this.conexiones,
  });

  // Lista de conexiones web completas.
  // Todas se consideran activas y se prueban al guardar.
  final List<WebEndpoint> conexiones;

  Map<String, dynamic> toMap() {
    return {
      'conexiones': conexiones.map((e) => e.toMap()).toList(),
    };
  }

  static WebConfig fromMap(Map<dynamic, dynamic> map) {
    final conexiones = <WebEndpoint>[];

    // Nuevo formato: lista de conexiones completas.
    final rawConexiones = map['conexiones'];
    if (rawConexiones is List) {
      for (final item in rawConexiones) {
        if (item is Map) {
          conexiones.add(WebEndpoint.fromMap(item));
        }
      }
    }

    // Formato anterior 1: lista de URLs con proyecto/usuario/contrasena comunes.
    final rawUrls = map['urls'];
    if (conexiones.isEmpty && rawUrls is List) {
      final proyecto = map['proyecto'] as String? ?? '';
      final usuario = map['usuario'] as String?;
      final contrasena = map['contrasena'] as String?;
      for (final item in rawUrls) {
        if (item is String && item.trim().isNotEmpty) {
          conexiones.add(
            WebEndpoint(
              idEmpresa: null,
              empresa: '',
              url: item.trim(),
              proyecto: proyecto,
              usuario: usuario,
              contrasena: contrasena,
            ),
          );
        }
      }
    }

    // Formato anterior 2: una sola URL con proyecto/usuario/contrasena comunes.
    final legacyUrl = map['url'];
    if (conexiones.isEmpty && legacyUrl is String && legacyUrl.trim().isNotEmpty) {
      conexiones.add(
        WebEndpoint(
          idEmpresa: null,
          empresa: '',
          url: legacyUrl.trim(),
          proyecto: map['proyecto'] as String? ?? '',
          usuario: map['usuario'] as String?,
          contrasena: map['contrasena'] as String?,
        ),
      );
    }

    return WebConfig(conexiones: conexiones);
  }
}
