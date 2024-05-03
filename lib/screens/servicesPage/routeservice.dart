import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:location/location.dart' as locationService;

class RouteServicePage extends StatefulWidget {
  final GptFeed feed;

  RouteServicePage({required this.feed});

  @override
  _RouteServicePageState createState() => _RouteServicePageState();
}

class _RouteServicePageState extends State<RouteServicePage> {
  final start = TextEditingController();
  final end = TextEditingController();
  bool isVisible = false;
  var startv1 = 0.0;
  var startv2 = 0.0;
  var endv1 = 0.0;
  var endv2 = 0.0;

  List<LatLng> routpoints = [LatLng(52.05884, -1.345583)];

  Future<locationService.LocationData?> getLocation() async {
    final location = locationService.Location();
    bool _serviceEnabled;
    locationService.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locationService.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != locationService.PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  @override
  void initState() {
    super.initState();
    // Call _performRouting in initState
    _performRouting();
  }

  Future<void> _performRouting() async {
    // Show loader while waiting for getLocation
    setState(() {
      isVisible = false;
    });

    locationService.LocationData? locationData = await getLocation();

    if (locationData == null) {
      // Handle the case where locationData is null (permission denied, etc.) here location data accessed
      return;
    }

    var v1 = locationData.latitude;
    var v2 = locationData.longitude;
    var v3 = widget.feed.latitude;
    var v4 = widget.feed.longitude;

    var url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
    var response = await http.get(url);

    setState(() {
      routpoints = [];
      var ruter =
          jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
      for (int i = 0; i < ruter.length; i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "");
        reep = reep.replaceAll("]", "");
        var lat1 = reep.split(',');
        var long1 = reep.split(",");
        routpoints.add(LatLng(double.parse(lat1[1]), double.parse(long1[0])));
      }
      if (v1 != null && v2 != null && v3 != null && v4 != null) {
        isVisible = true;
        startv1 = v1;
        startv2 = v2;
        endv1 = v3;
        endv2 = v4;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Routing',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.grey[500],
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Add a back button icon
          onPressed: () {
            // Navigate back to the previous page
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 700,
                  width: 400,
                  child: Visibility(
                    visible: isVisible,
                    child: FlutterMap(
                      options: MapOptions(
                        center: routpoints[0],
                        zoom: 10,
                      ),
                      nonRotatedChildren: [
                        AttributionWidget.defaultWidget(
                            source: 'OpenStreetMap contributors',
                            onSourceTapped: null),
                      ],
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(
                                points: routpoints,
                                color: Colors.blue,
                                strokeWidth: 9),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: LatLng(startv1,
                                  startv2), // Start location coordinates
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons
                                      .location_on, // Use the location icon for start
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Marker(
                              width: 50.0,
                              height: 50.0,
                              point: LatLng(
                                  endv1, endv2), // End location coordinates
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.flag, // Use the flag icon for end
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
