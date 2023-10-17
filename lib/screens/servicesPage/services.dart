import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccw/consts/env.dart' show backendUrl;

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<LatLng> routePoints = [LatLng( 18.516726, 73.856255)];
  List<Marker> dynamicMarkers = []; // List to store dynamic markers

  @override
  void initState() {
    super.initState();
    fetchLocations(); // Call the function to fetch locations on init
  }

  Future<void> fetchLocations() async {
    final response = await http.get(Uri.parse('$backendUrl/api/post/all-locations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        print(data);
        dynamicMarkers = data.map((location) {
          final double latitude = location[0];
          final double longitude = location[1];
          return Marker(
            width: 50.0,
            height: 50.0,
            point: LatLng(latitude, longitude),
            builder: (ctx) => Container(
              child: Icon(
                Icons.location_on,
                color: Colors.blue, // You can set the marker color here
              ),
            ),
          );
        }).toList();
      });
    } else {
      // Handle error
      print('Failed to fetch locations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: actionBarRow(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
         // Disable the back button
       
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 620,
                  width: 400,
                  child: FlutterMap(
                    options: MapOptions(
                      center: routePoints[0],
                      zoom: 10,
                    ),
                    nonRotatedChildren: [
                      AttributionWidget.defaultWidget(
                        source: 'OpenStreetMap contributors',
                        onSourceTapped: null,
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          // Add your dynamic markers here
                          ...dynamicMarkers,
                        ],
                      ),
                    ],
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
