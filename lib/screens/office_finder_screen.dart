// lib/screens/office_finder_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/providers/language_provider.dart';
import '../core/providers/accessibility_provider.dart';

class OfficeFinderScreen extends StatelessWidget {
  const OfficeFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final accessibility = Provider.of<AccessibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text(
          'Office Finder',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search CNSS, CNAM, Municipalities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    selected: true,
                    label: const Text('Wheelchair'),
                    onSelected: (_) {},
                    backgroundColor: const Color(0xFF0A3D62),
                    selectedColor: const Color(0xFF0A3D62),
                    labelStyle: const TextStyle(color: Colors.white),
                    avatar: const Icon(Icons.accessible, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: false,
                    label: const Text('Distance'),
                    onSelected: (_) {},
                    avatar: const Icon(Icons.directions_walk, size: 18),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: false,
                    label: const Text('Open Now'),
                    onSelected: (_) {},
                    avatar: const Icon(Icons.access_time, size: 18),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Map Section
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(36.8065, 10.1815), // Tunis area
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'tn.gov.officefinder',
                    ),
                    MarkerLayer(
                      markers: [
                        // Your location (blue circle)
                        Marker(
                          point: const LatLng(36.8065, 10.1815),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                        // CNSS Tunis (red marker)
                        Marker(
                          point: const LatLng(36.8080, 10.1830),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                        // CNAM Belvédère (green marker)
                        Marker(
                          point: const LatLng(36.8120, 10.1750),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Map Labels (You, CNSS Tunis, CNAM Belvédère, Municipality)
                Positioned(
                  top: 20,
                  left: 50,
                  child: _buildMapLabel('You', Colors.blue),
                ),
                Positioned(
                  top: 60,
                  left: 180,
                  child: _buildMapLabel('CNSS Tunis', Colors.red),
                ),
                Positioned(
                  bottom: 80,
                  right: 40,
                  child: _buildMapLabel('CNAM Belvédère', Colors.green),
                ),
                Positioned(
                  bottom: 120,
                  left: 40,
                  child: _buildMapLabel('Municipality', Colors.grey),
                ),
              ],
            ),
          ),

          // Nearby Offices Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nearby Offices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Office Cards
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildOfficeCard(
                  context,
                  title: 'CNAM Belvédère',
                  distance: '1.2 km from your location',
                  isOpen: true,
                  hasWheelchair: true,
                  closesAt: '16:30',
                  isSaved: true,
                ),
                const SizedBox(height: 12),
                _buildOfficeCard(
                  context,
                  title: 'CNSS Tunis Centre',
                  distance: '2.1 km from your location',
                  isOpen: true,
                  hasWheelchair: true,
                  closesAt: '17:00',
                  isSaved: false,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF0A3D62),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Assistant'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Offices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMapLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOfficeCard(
    BuildContext context, {
    required String title,
    required String distance,
    required bool isOpen,
    required bool hasWheelchair,
    required String closesAt,
    required bool isSaved,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOpen ? 'OPEN' : 'CLOSED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              distance,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasWheelchair)
                  const Chip(
                    label: Text('Full Wheelchair Access'),
                    avatar: Icon(Icons.accessible, size: 18),
                    backgroundColor: Color(0xFFE3F2FD),
                    labelStyle: TextStyle(color: Color(0xFF0A3D62)),
                  ),
                const Spacer(),
                Text(
                  'Closes at $closesAt',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Save Offline'),
                const Spacer(),
                Switch(
                  value: isSaved,
                  onChanged: (_) {},
                  activeColor: const Color(0xFF0A3D62),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}