import 'package:flutter/material.dart';
import 'package:keyah/styles/colors.dart';
import 'package:keyah/models/association.dart';
import 'package:keyah/services/database_helper.dart';
import 'package:keyah/widgets/association_card.dart';
import 'package:keyah/widgets/details_bottom_sheet.dart';
import 'package:keyah/widgets/map_modal.dart';

class AssociationSearchScreen extends StatefulWidget {
  final List<Association> allAssociations;

  const AssociationSearchScreen({required this.allAssociations, super.key});

  @override
  State<AssociationSearchScreen> createState() => _AssociationSearchScreenState();
}

class _AssociationSearchScreenState extends State<AssociationSearchScreen> {
  // Controladores y Servicios
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Estado de la pantalla
  List<Association> _displayedAssociations = [];
  bool _isLoading = false;
  String? _selectedFilter;
  
  // LISTA DE CATEGORÍAS
  final List<String> _availableTopics = [
    'Arte y cultura',
    'Asistencia social y atención a desastres',
    'Desarrollo social y económico',
    'Educación',
    'Filantropía y voluntariado',
    'Investigación',
    'Medio ambiente y protección animal',
    'No especificado'
  ];

  @override
  void initState() {
    super.initState();
    _displayedAssociations = widget.allAssociations;
  }

  // Función para recargar datos desde la DB aplicando filtros
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final results = await _dbHelper.getAssociations(
        searchTerm: _searchController.text,
        tematica: _selectedFilter,
      );
      setState(() {
        _displayedAssociations = results;
      });
    } catch (e) {
      debugPrint('Error consultando DB: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Helper para mostrar detalles de contacto
  void _showDetails(Association association) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetailsBottomSheet(association: association),
    );
  }

  // Helper para mostrar mapa
  void _showMap(Association association) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) => MapModal(
        address: association.direccion,
        city: association.ciudad,
        state: association.estado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeyahColors.lightBackground,
      appBar: AppBar(
        title: const Text('Kéyah', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        // Barra de búsqueda integrada en la AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar organización, ciudad...',
                prefixIcon: const Icon(Icons.search, color: KeyahColors.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _selectedFilter = null);
                        _refreshData();
                      },
                    )
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                _refreshData();
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Área de Filtros (Chips Horizontales)
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterChip('Todas', null),
                  ..._availableTopics.map((topic) => 
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildFilterChip(topic, topic),
                    )
                  ),
                ],
              ),
            ),
          ),
          // Contador de resultados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  '${_displayedAssociations.length} resultados',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                if (_isLoading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 12, height: 12, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  ),
                ]
              ],
            ),
          ),
          // Lista de Resultados
          Expanded(
            child: _displayedAssociations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  // --- AQUÍ ESTÁ EL CAMBIO CLAVE ---
                  // Usamos fromLTRB para dar 100 de padding abajo.
                  // Left: 16, Top: 16, Right: 16, Bottom: 100
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), 
                  itemCount: _displayedAssociations.length,
                  itemBuilder: (context, index) {
                    final assoc = _displayedAssociations[index];
                    return AssociationCard(
                      association: assoc,
                      onDetailsPressed: () => _showDetails(assoc),
                      onMapPressed: () => _showMap(assoc),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  // Widget auxiliar para construir los Chips de filtro
  Widget _buildFilterChip(String label, String? topicValue) {
    final isSelected = _selectedFilter == topicValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: KeyahColors.primaryBlue,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : KeyahColors.darkText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() {
          if (isSelected) {
            _selectedFilter = null;
          } else {
            _selectedFilter = topicValue;
          }
        });
        _refreshData();
      },
    );
  }

  // Estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No encontramos coincidencias',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedFilter = null);
              _refreshData();
            },
            child: const Text('Limpiar búsqueda'),
          )
        ],
      ),
    );
  }
}