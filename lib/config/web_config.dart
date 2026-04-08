class WebConfig {
  WebConfig({
    required this.url,
    required this.proyecto,
    this.usuario,
    this.contrasena,
  });

  // URL base del servidor web (ej: https://miempresa.com).
  final String url;
  // Nombre del proyecto/entorno en el servidor.
  final String proyecto;
  // Usuario opcional para autenticar en el servicio web.
  final String? usuario;
  // Contrasena opcional para autenticar en el servicio web.
  final String? contrasena;

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'proyecto': proyecto,
      'usuario': usuario,
      'contrasena': contrasena,
    };
  }

  static WebConfig fromMap(Map<dynamic, dynamic> map) {
    return WebConfig(
      url: map['url'] as String,
      proyecto: map['proyecto'] as String,
      usuario: map['usuario'] as String?,
      contrasena: map['contrasena'] as String?,
    );
  }
}
