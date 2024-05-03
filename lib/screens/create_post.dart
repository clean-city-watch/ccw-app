import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:http_parser/http_parser.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:latlong2/latlong.dart'; // Use latlong2 package for LatLng
import 'package:flutter_map/flutter_map.dart';

// create issue page.

class CreatePost extends StatefulWidget {
  static String id = 'create_post_screen';
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  LatLng? _selectedLocation;

  List<dynamic> dynamicMarkers = [];

  bool __spanLocationPicker = false;
  bool isPickingLocation = true;
  LocationData? locationData;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    latitudeController = TextEditingController(text: "");
    longitudeController = TextEditingController(text: "");
    getLocation();
  }

  Future<void> getLocation() async {
    final location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await location.getLocation();
    setState(() {
      this.locationData = locationData;
      latitudeController.text = locationData.latitude.toString();
      longitudeController.text = locationData.longitude.toString();
    });
  }

  Future<void> handleImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void handleImageRemove() {
    print("");
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> handleLocationToggle() async {
    if (!isPickingLocation) {
      await getLocation();
    }
    setState(() {
      isPickingLocation = !isPickingLocation;
      __spanLocationPicker = !__spanLocationPicker;
    });
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribute evenly
                children: [
                  Expanded(
                    // Allow each TextField to expand as needed
                    child: TextFormField(
                      readOnly: true,
                      controller: latitudeController,
                      decoration: InputDecoration(labelText: 'Latitude'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Latitude is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 20.0), // Adjust spacing as needed
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: longitudeController,
                      decoration: InputDecoration(labelText: 'Longitude'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Longitude is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text('Pick Location:'),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleLocationToggle,
                    child: Text(isPickingLocation ? 'Automatic' : 'Manual'),
                  ),
                ],
              ),
              __spanLocationPicker == true
                  ? SizedBox(
                      height: 300,
                      width: 400,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng(18.516726, 73.856255),
                          zoom: 10,
                          onTap: (point, latlng) {
                            setState(() {
                              _selectedLocation = latlng;
                              latitudeController.text =
                                  latlng.latitude.toString();
                              longitudeController.text =
                                  latlng.longitude.toString();
                            });
                          },
                        ),
                        nonRotatedChildren: [
                          AttributionWidget.defaultWidget(
                            source: 'OpenStreetMap contributors',
                            onSourceTapped: null,
                          ),
                        ],
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              // Add your dynamic markers here
                              if (_selectedLocation != null)
                                Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: _selectedLocation!,
                                  builder: (ctx) => Container(
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors
                                          .red, // You can set the marker color here
                                    ), // Customize marker appearance
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(),
              SizedBox(height: 10),
              selectedImage != null
                  ?
                  // Image.asset(
                  //     'assets/images/garbeg.jpg', // Replace with your image path
                  //     height: 200,
                  //   )
                  Image.file(
                      selectedImage!,
                      height: 200,
                    )
                  : SizedBox(),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: handleImagePicker,
                    child: Text('Pick Image'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleImageRemove,
                    child: Text('Remove Image'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  bool isValidated = _formKey.currentState!.validate();
                  if (isValidated) {
                    final prefs = await SharedPreferences.getInstance();
                    final userInfo = prefs.getString('userinfo');

                    if (userInfo != null) {
                      Map<String, dynamic> userInfoMap = json.decode(userInfo);
                      String accessToken = userInfoMap['access_token'];

                      final url = Uri.parse('$backendUrl/api/post');

                      if (selectedImage == null) {
                        return;
                      }

                      var request = http.MultipartRequest('POST', url)
                        ..files.add(await http.MultipartFile.fromPath(
                            'file', selectedImage!.path))
                        ..fields['title'] = _titleController.text
                        ..fields['content'] = _contentController.text
                        ..fields['city'] = _cityController.text
                        ..fields['latitude'] = latitudeController.text
                        ..fields['longitude'] = longitudeController.text
                        ..fields['published'] = 'true'
                        ..fields['type'] = 'ISSUE'
                        ..fields['authorId'] = userInfoMap['id'].toString()
                        ..headers.addAll({
                          "Authorization": "Bearer $accessToken",
                        });

                      print('cooked request!');
                      final response = await request.send();
                      print('response time....');

                      if (response.statusCode == 201) {
                        signUpAlert(
                          onPressed: () async {
                            print('back to the feeds page');
                            Navigator.popAndPushNamed(context, CreatePost.id);
                            Navigator.pushNamed(context, WelcomeScreen.id);
                          },
                          title: 'Post Upload',
                          desc: 'Post uploaded successfully!',
                          btnText: 'Feed Now',
                          context: context,
                        ).show();
                      } else if (response.statusCode == 401 ||
                          response.statusCode == 403) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => LoginScreen(),
                          ),
                        );
                      } else {
                        signUpAlert(
                          onPressed: () async {
                            // print(response.toString());
                            Navigator.popAndPushNamed(context, CreatePost.id);
                          },
                          title: 'Post Upload',
                          desc: "Please complete your profile first",
                          btnText: 'Feed Now',
                          context: context,
                        ).show();
                      }
                    }
                    ;
                  }
                },
                child: Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
