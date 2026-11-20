import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/reports_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ReportsService _reportsService = ReportsService();
  final MapController _mapController = MapController();

  List<dynamic> _reports = [];
  bool _loading = true;

  // Coordenadas base: Dolores Hidalgo, Guanajuato
  final LatLng _defaultCenter = const LatLng(21.1561, -100.9308);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    final data = await _reportsService.getReports();
    if (!mounted) return;
    setState(() {
      _reports = data;
      _loading = false;
    });
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Crítica':
        return Colors.red.shade900;
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
      default:
        return Colors.green;
    }
  }

  void _showReportDetails(Map<String, dynamic> report) {
    final String photoBase64 = report['photoBase64'] ?? '';
    final String species = report['species'] ?? 'Animal';
    final String urgency = report['urgency'] ?? 'Media';
    final String description = report['description'] ?? 'Sin descripción';
    final String status = report['status'] ?? 'Pendiente';
    final double lat = (report['latitude'] as num).toDouble();
    final double lon = (report['longitude'] as num).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: _getUrgencyColor(urgency)),
                      const SizedBox(width: 8),
                      Text(
                        '$species - Urgencia $urgency',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(status),
                    backgroundColor: Colors.teal.shade50,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (photoBase64.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(photoBase64),
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Sin fotografía adjunta'),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordenadas: ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = _reports.map((report) {
      final double lat = (report['latitude'] as num).toDouble();
      final double lon = (report['longitude'] as num).toDouble();
      final String urgency = report['urgency'] ?? 'Media';

      return Marker(
        point: LatLng(lat, lon),
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: () => _showReportDetails(report),
          child: Container(
            decoration: BoxDecoration(
              color: _getUrgencyColor(urgency),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.pawrescue.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        if (_loading)
          const Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Cargando alertas...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 16,
          left: 16,
          child: Chip(
            avatar: const Icon(Icons.location_on, size: 18, color: Colors.teal),
            label: Text('Reportes activos: ${_reports.length}'),
            backgroundColor: Colors.white,
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _loadReports,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            tooltip: 'Actualizar mapa',
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}