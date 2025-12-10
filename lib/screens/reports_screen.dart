import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/services/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;

  // Variables para almacenar los datos
  Map<String, int> _kpiStats = {};
  List<Map<String, dynamic>> _globalTematica = [];
  List<Map<String, dynamic>> _topCities = [];
  Map<String, List<Map<String, dynamic>>> _groupedStateStats = {};
  
  // Variable para almacenar los estados que NO tienen asociaciones
  List<String> _missingStates = []; 

  // Lista OFICIAL de los 32 Estados de México
  final List<String> _allMexicanStates = const [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche', 
    'Coahuila', 'Colima', 'Chiapas', 'Chihuahua', 'Ciudad de México', 
    'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco', 
    'Estado de México', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León', 
    'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí', 
    'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala', 
    'Veracruz', 'Yucatán', 'Zacatecas'
  ];

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    try {
      final results = await Future.wait([
        _dbHelper.getGeneralStats(),       // index 0
        _dbHelper.getGlobalTematicaStats(),// index 1
        _dbHelper.getTopCities(),          // index 2
        _dbHelper.getTematicaByState(),    // index 3
      ]);

      if (mounted) {
        setState(() {
          _kpiStats = results[0] as Map<String, int>;
          _globalTematica = results[1] as List<Map<String, dynamic>>;
          _topCities = results[2] as List<Map<String, dynamic>>;
          
          final rawStateList = results[3] as List<Map<String, dynamic>>;
          _groupedStateStats = {};
          
          Set<String> foundStatesNames = {};

          for (var item in rawStateList) {
            String estado = item['estado'] ?? 'Desconocido';
            foundStatesNames.add(estado.trim());

            if (!_groupedStateStats.containsKey(estado)) {
              _groupedStateStats[estado] = [];
            }
            _groupedStateStats[estado]!.add(item);
          }

          // CALCULO DE FALTANTES
          _missingStates = _allMexicanStates.where((officialState) {
            return !foundStatesNames.any((found) => 
              found.toLowerCase() == officialState.toLowerCase()
            );
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando reportes: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Reportes y Estadísticas', 
          style: TextStyle(fontWeight: FontWeight.bold, color: KeyahColors.darkText)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: KeyahColors.primaryBlue))
          : SingleChildScrollView(
              // CAMBIO AQUÍ: Aumentamos el padding inferior de 80 a 130
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SECCIÓN DE KPIs
                  Row(
                    children: [
                      _buildKpiCard('Asociaciones', _kpiStats['total_asociaciones'] ?? 0, Colors.blue),
                      const SizedBox(width: 12),
                      _buildKpiCard('Estados', _kpiStats['total_estados'] ?? 0, Colors.orange),
                      const SizedBox(width: 12),
                      _buildKpiCard('Ciudades', _kpiStats['total_ciudades'] ?? 0, Colors.green),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  // 2. SECCIÓN TEMÁTICA GLOBAL
                  _buildSectionTitle('Distribución por Temática'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      children: _globalTematica.map((item) {
                        int total = _kpiStats['total_asociaciones'] ?? 1;
                        int cantidad = item['cantidad'];
                        double porcentaje = cantidad / total;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['tematica'], 
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '$cantidad (${(porcentaje * 100).toStringAsFixed(1)}%)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: porcentaje,
                                  backgroundColor: Colors.grey[200],
                                  color: KeyahColors.primaryBlue,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. SECCIÓN TOP CIUDADES
                  _buildSectionTitle('Top Ciudades con Mayor Presencia'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: _cardDecoration(),
                    child: Column(
                      children: List.generate(_topCities.length, (index) {
                        final city = _topCities[index];
                        return Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: index < 3 ? KeyahColors.actionOrange : Colors.grey[300],
                                foregroundColor: Colors.white,
                                radius: 14,
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(city['ciudad'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(city['estado'], style: const TextStyle(fontSize: 12)),
                              trailing: Text(
                                '${city['cantidad']}', 
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: KeyahColors.primaryBlue)
                              ),
                            ),
                            if (index < _topCities.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. SECCIÓN DESGLOSE POR ESTADO
                  _buildSectionTitle('Detalle por Estado y Temática'),
                  const SizedBox(height: 12),
                  ..._groupedStateStats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: _cardDecoration(),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: KeyahColors.darkText),
                            ),
                            subtitle: Text(
                              '${entry.value.fold(0, (sum, item) => sum + (item['cantidad'] as int))} asociaciones',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            leading: const Icon(Icons.map, color: KeyahColors.primaryBlue),
                            children: entry.value.map((tema) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                title: Text(tema['tematica']),
                                trailing: Text(
                                  tema['cantidad'].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }),

                  // 5. NUEVA SECCIÓN: ESTADOS SIN COBERTURA
                  if (_missingStates.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Áreas de Oportunidad',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: Colors.orange
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Los siguientes estados aún no cuentan con asociaciones registradas bajo los criterios actuales (CLUNI + AIT + Donataria).',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _missingStates.map((state) {
                              return Chip(
                                label: Text(state),
                                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KeyahColors.darkText),
    );
  }

  Widget _buildKpiCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    );
  }
}