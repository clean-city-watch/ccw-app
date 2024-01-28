import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<LatLng> routePoints = [LatLng( 18.516726, 73.856255)];
  List<dynamic> dynamicMarkers = []; // List to store dynamic markers
  Map<String, dynamic> countData = {"content": [], "all": 0, "open": 0, "inprogress": 0, "resolved": 0};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: 'Pune');
    fetchLocations('$backendUrl/api/post/all-locations'); // Call the function to fetch locations on init
  }

  void handleBellIconTap(String city) {
      // Add your logic here
      print('Bell icon tapped!');
      print(city);
      fetchLocations('$backendUrl/api/post/all-locations?city=$city');
      // Call any other functions or perform any actions you need
    }


  Future<void> fetchLocations(String url) async {
     final prefs = await SharedPreferences.getInstance();
      String? userInfo = prefs.getString('userinfo');

      if(userInfo != null) {
          Map<String, dynamic> userInfoMap = json.decode(userInfo);
          String accessToken = userInfoMap['access_token'];
    
          var headers = {
            "Authorization": "Bearer ${accessToken}",
          };
          final response = await http.get(Uri.parse(url),headers: headers);
          if (response.statusCode == 200) {
            final  data = json.decode(response.body);
            setState(() {
             countData = data;
              dynamicMarkers = data['content'].map((location) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        readOnly: true,
                        maxLines: 1,
                        decoration: new InputDecoration(
                          // suffixIcon: Icon(CupertinoIcons.search),
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Search City',
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                            borderSide:  BorderSide(color: (Colors.grey[300])!, width: 0.5),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Call your function when the bell icon is tapped
                        handleBellIconTap(_searchController.text);
                      },
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Icon(CupertinoIcons.search, size: 26),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CountCard(
                        title: 'All',
                        count: countData['all'] ?? 0,
                        icon: Icons.description,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: CountCard(
                        title: 'Open',
                        count: countData['open'] ?? 0,
                        icon: Icons.comment,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      child: CountCard(
                        title: 'Active',
                        count: countData['inprogress'] ?? 0,
                        icon: Icons.thumb_up,
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: CountCard(
                        title: 'Resolved',
                        count: countData['resolved'] ?? 0,
                        icon: Icons.feedback,
                        color: const Color.fromARGB(255, 137, 136, 136),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 460,
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



class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  CountCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            // SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
