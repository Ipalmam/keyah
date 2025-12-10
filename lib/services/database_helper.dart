import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:keyah/models/association.dart';

class DatabaseHelper {
  static Database? _database;
  static const String databaseName = 'keyah_database.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);

    bool exists = await databaseExists(path);

    if (!exists) {
      debugPrint('Copiando base de datos por primera vez...');
      try {
        ByteData data = await rootBundle.load(join('assets', 'database', databaseName));
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        debugPrint('Error crítico copiando DB: $e');
        throw Exception('Error al copiar la base de datos.');
      }
    }
    
    return await openDatabase(path, readOnly: true);
  }

  // --------------------------------------------------------------------------
  // LÓGICA DE CONSULTA OPTIMIZADA (SIN BUCLE N+1)
  // --------------------------------------------------------------------------

  Future<List<Association>> getAssociations({String? searchTerm, String? tematica}) async {
    final db = await database;
    
    String sql = '''
      SELECT id, nombre, tematica, direccion, ciudad, estado, latitud, longitud, qr_imagen, monto_sugerido 
      FROM asociaciones 
      WHERE 1=1
    ''';
    List<dynamic> params = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      sql += ' AND (nombre LIKE ? OR ciudad LIKE ? OR tematica LIKE ?)';
      params.add('%$searchTerm%');
      params.add('%$searchTerm%');
      params.add('%$searchTerm%');
    }

    if (tematica != null && tematica.isNotEmpty && tematica != 'Todas') {
      sql += ' AND tematica = ?';
      params.add(tematica);
    }
    
    sql += ' ORDER BY nombre ASC';
    
    // Ejecutamos UNA SOLA consulta rápida
    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, params);
    
    // Mapeamos directamente. NO consultamos teléfonos ni correos aquí.
    return maps.map((map) => Association.fromMap(map)).toList();
  }
  
  // --------------------------------------------------------------------------
  // CONSULTAS BAJO DEMANDA (Detalles de contacto)
  // --------------------------------------------------------------------------

  Future<List<String>> getPhonesForAssociation(int asocId) async {
    final db = await database;
    final List<Map<String, dynamic>> phoneMaps = await db.query(
      'telefonos',
      columns: ['numero'],
      where: 'asociacion_id = ?',
      whereArgs: [asocId],
    );
    return phoneMaps.map((map) => map['numero'] as String).toList();
  }

  Future<List<String>> getEmailsForAssociation(int asocId) async {
    final db = await database;
    final List<Map<String, dynamic>> emailMaps = await db.query(
      'correos',
      columns: ['email'],
      where: 'asociacion_id = ?',
      whereArgs: [asocId],
    );
    return emailMaps.map((map) => map['email'] as String).toList();
  }

  // --------------------------------------------------------------------------
  // NUEVA SECCIÓN: REPORTES Y ESTADÍSTICAS
  // --------------------------------------------------------------------------

  // 1. KPI Generales (Totales para tarjetas superiores)
  Future<Map<String, int>> getGeneralStats() async {
    final db = await database;
    
    // Total de Asociaciones
    final totalAsoc = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM asociaciones')
    ) ?? 0;

    // Total de Estados Cubiertos
    final totalEstados = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(DISTINCT estado) FROM asociaciones')
    ) ?? 0;

    // Total de Ciudades Cubiertas
    final totalCiudades = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(DISTINCT ciudad) FROM asociaciones')
    ) ?? 0;

    return {
      'total_asociaciones': totalAsoc,
      'total_estados': totalEstados,
      'total_ciudades': totalCiudades,
    };
  }

  // 2. Reporte Global por Temática (Para gráfico de pastel)
  // Devuelve: [{'tematica': 'Salud', 'cantidad': 15}, ...]
  Future<List<Map<String, dynamic>>> getGlobalTematicaStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tematica, COUNT(*) as cantidad 
      FROM asociaciones 
      WHERE tematica IS NOT NULL AND tematica != ''
      GROUP BY tematica 
      ORDER BY cantidad DESC
    ''');
  }

  // 3. Top Ciudades con más Asociaciones (Ranking)
  // Devuelve: [{'ciudad': 'Chihuahua', 'estado': 'CHIHUAHUA', 'cantidad': 20}, ...]
  Future<List<Map<String, dynamic>>> getTopCities() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ciudad, estado, COUNT(*) as cantidad 
      FROM asociaciones 
      GROUP BY ciudad, estado 
      ORDER BY cantidad DESC 
      LIMIT 10
    ''');
  }

  // 4. Temática por Estado (Desglose geográfico macro)
  // Devuelve: [{'estado': 'CHIHUAHUA', 'tematica': 'Salud', 'cantidad': 5}, ...]
  Future<List<Map<String, dynamic>>> getTematicaByState() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT estado, tematica, COUNT(*) as cantidad 
      FROM asociaciones 
      WHERE estado IS NOT NULL
      GROUP BY estado, tematica 
      ORDER BY estado ASC, cantidad DESC
    ''');
  }

  // 5. Temática por Ciudad (Desglose geográfico micro)
  // Devuelve: [{'ciudad': 'Juárez', 'tematica': 'Legal', 'cantidad': 3}, ...]
  Future<List<Map<String, dynamic>>> getTematicaByCity() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ciudad, estado, tematica, COUNT(*) as cantidad 
      FROM asociaciones 
      WHERE ciudad IS NOT NULL
      GROUP BY ciudad, estado, tematica 
      ORDER BY ciudad ASC, cantidad DESC
    ''');
  }

  // Recuperar Redes Sociales
  // Devuelve una lista de Mapas: [{'tipo': 'facebook', 'url': '...', 'usuario': '@...'}, ...]
  Future<List<Map<String, dynamic>>> getSocialNetworks(int asocId) async {
    final db = await database;
    return await db.query(
      'redes_sociales',
      columns: ['tipo', 'url', 'usuario'],
      where: 'asociacion_id = ?',
      whereArgs: [asocId],
    );
  }
}