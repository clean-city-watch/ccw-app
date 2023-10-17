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

  bool isPickingLocation = false;
  LocationData? locationData;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
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
              locationData != null
                  ? Text(
                      'Current Location: Latitude: ${locationData!.latitude}, Longitude: ${locationData!.longitude}',
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
              selectedImage != null
                  ? Image.asset(
                      'assets/images/garbeg.jpg', // Replace with your image path
                      height: 200,
                    )
                  // Image.file(
                  //     selectedImage!,
                  //     height: 200,
                  //   )
                  : SizedBox(),
              ElevatedButton(
                onPressed: () async {
                  // _formKey.currentState!.validate()
                  if (true) {
                    final prefs = await SharedPreferences.getInstance();
                    final userInfo = prefs.getString('userinfo');
                   
                    if(userInfo != null) {
                      Map<String, dynamic> userInfoMap = json.decode(userInfo);
                                          print({'title': _titleController.text,
                            'content': _contentController.text,
                            'city': _cityController.text,
                            'published': true,
                            'latitude': locationData!.latitude.toString(),
                            'longitude': locationData!.longitude.toString(),
                            'authorId': userInfoMap['id'].toString(),
                            'typeof': userInfoMap['id'].runtimeType,
                            'file':  selectedImage,
                            });

                    try{
                    

                      final response = await http.post(
                          Uri.parse('$backendUrl/api/post'),
                          body: {
                            'title': _titleController.text,
                            'content': _contentController.text,
                            'city': _cityController.text,
                            'published': 'true',
                            'latitude': locationData!.latitude.toString(),
                            'longitude': locationData!.longitude.toString(),
                            'authorId': userInfoMap['id'].toString(),
                            
                          },
                        );
                        print(response.body);
                        print(response.statusCode);
                        print('success');
                         if (response.statusCode == 201) {
                          signUpAlert(
                              onPressed: () async {
                               print('back to the feeds page');
                                Navigator.popAndPushNamed(
                                      context, CreatePost.id);
                                 Navigator.pushNamed(context, WelcomeScreen.id);
                              },
                              title: 'Post Upload',
                              desc:
                                  'Post uploaded successfully!',
                              btnText: 'Feed Now',
                              context: context,
                            ).show();
                          
                         
                          
                              
                         }


                    }catch(e){
                      print(e);
                    }
                    // try {
                    //   var request = http.MultipartRequest('POST', Uri.parse('$backendUrl/api/post'));


                    //   print('inside the send after request');
                    //   // Add file to the request
                    //   var stream = http.ByteStream(selectedImage!.openRead());
                    //   var length = await selectedImage!.length();
                    //   print(stream);
                    //   print('stream was ');
                    //   var multipartFile = http.MultipartFile(
                    //     'file', // Field name expected by your API
                    //     stream,
                    //     length,
                    //     filename: selectedImage!.path.split('/').last,
                    //     contentType:  MediaType('application', 'octet-stream'), // Specify the content type of the file
                    //   );
                    //   request.files.add(multipartFile);

                    //   // Add other form data
                    //   request.fields['title'] = _titleController.text;
                    //   request.fields['content'] = _contentController.text;
                    //   request.fields['city'] = _cityController.text;
                    //   request.fields['published'] = 'true';
                    //   request.fields['latitude'] = locationData!.latitude.toString();
                    //   request.fields['longitude'] = locationData!.longitude.toString();
                    //   request.fields['authorId'] = userInfoMap['id'].toString();

                    //   // Send the request and get the response
                    //   var response = await request.send();

                    //   if (response.statusCode == 201) {
                    //     print('File uploaded successfully');
                    //     // Handle successful response here
                    //   } else {
                    //     print('File upload failed with status code: ${response.statusCode}');
                    //     // Handle error response here
                    //   }
                    // } catch (e) {
                    //   print('Error uploading file: $e');
                    //   // Handle any exceptions here
                    // }

                    };



                    // Submit the form and handle post creation
                    // You can access _titleController.text, _contentController.text, _cityController.text
                    // locationData, and selectedImage for your post data
                  }
                },
                child: Text('Create Post'),
              ),
              isPickingLocation
                  ? Text('Manual Location Picker Widget Goes Here')
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

