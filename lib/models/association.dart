class Association {
  final int id;
  final String nombre;
  final String tematica;
  final String direccion;
  final String ciudad;
  final String estado;
  final double latitud;
  final double longitud;
  final String? qrImagen;
  final String? montoSugerido;
  // Listas para los detalles (Relación 1 a muchos)
  final List<String> telefonos;
  final List<String> correos;


  const Association({
    required this.id,
    required this.nombre,
    required this.tematica,
    required this.direccion,
    required this.ciudad,
    required this.estado,
    required this.latitud,
    required this.longitud,
    this.qrImagen,
    this.montoSugerido,
    this.telefonos = const [],
    this.correos = const [],
  });

  // Factory ajustado a las columnas REALES de tu tabla 'asociaciones' en SQLite
  factory Association.fromMap(Map<String, dynamic> map, {List<String>? phones, List<String>? emails}) {
    return Association(
      id: map['id'] as int,
      nombre: map['nombre'] as String? ?? 'Sin Nombre',
      tematica: map['tematica'] as String? ?? 'General',
      direccion: map['direccion'] as String? ?? '',
      ciudad: map['ciudad'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      qrImagen: map['qr_imagen'], 
      montoSugerido: map['monto_sugerido'],
      telefonos: phones ?? [],
      correos: emails ?? [],
    );
  }
}