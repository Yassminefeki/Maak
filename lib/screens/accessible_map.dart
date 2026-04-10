import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessible Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccessibleMap(),
    );
  }
}

class AccessibleMap extends StatefulWidget {
  const AccessibleMap({super.key});

  @override
  _AccessibleMapState createState() => _AccessibleMapState();
}

class _AccessibleMapState extends State<AccessibleMap> {
  Position? _currentPosition;
  List<LatLng> accessiblePlaces = [];
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    fetchAccessiblePlaces().then((places) {
      setState(() {
        accessiblePlaces = places;
      });
    });
    fetchRoute(); // Calculer l'itinéraire à partir de deux points
  }

  // Récupérer la position actuelle de l'utilisateur
  _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  // Fonction pour récupérer les lieux accessibles via Overpass API
  Future<List<LatLng>> fetchAccessiblePlaces() async {
    final overpassUrl =
        'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];(node["wheelchair"="yes"](48.1,11.4,48.2,11.7);way["wheelchair"="yes"](48.1,11.4,48.2,11.7););out body;>;out skel qt;';
    final response = await http.get(Uri.parse(overpassUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> accessiblePlaces = [];
      for (var element in data['elements']) {
        if (element['lat'] != null && element['lon'] != null) {
          accessiblePlaces.add(LatLng(element['lat'], element['lon']));
        }
      }
      return accessiblePlaces;
    } else {
      throw Exception('Failed to load accessible places');
    }
  }

  // Fonction pour calculer l'itinéraire accessible via OpenRouteService
  Future<void> fetchRoute() async {
    const apiKey = 'YOUR_OPENROUTESERVICE_KEY'; // Remplace par ta clé API
    final url =
        'https://api.openrouteservice.org/v2/directions/foot-wc?api_key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "coordinates": [
          [11.5820, 48.1351], // Coordonnée de départ (Munich)
          [11.5900, 48.1400] // Coordonnée d'arrivée
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routeCoordinates = data['features'][0]['geometry']['coordinates']
          .map<LatLng>((point) => LatLng(point[1], point[0]))
          .toList();
      setState(() {
        this.routeCoordinates = routeCoordinates;
      });
    } else {
      throw Exception('Failed to load route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carte des Routes Accessibles')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : LatLng(48.1351,
                  11.5820), // Coordonnée par défaut si la position de l'utilisateur est inconnue
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: accessiblePlaces.map((place) {
              return Marker(
                width: 80.0,
                height: 80.0,
                point: place,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40.0,
                ),
              );
            }).toList(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routeCoordinates,
                strokeWidth: 4.0,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
