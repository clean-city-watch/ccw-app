import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:ccw/screens/welcome.dart';

// create issue page.

class CreateOrganization extends StatefulWidget {
  static String id = 'organization_create_screen';
  @override
  _CreateOrganizationState createState() => _CreateOrganizationState();
}

class _CreateOrganizationState extends State<CreateOrganization> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _stateCodeController = TextEditingController();

  List<dynamic> dynamicMarkers = [];

  bool isPickingLocation = true;
  LocationData? locationData;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
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
                'Create Organization',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Type is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: InputDecoration(
                  labelText: 'Address 1',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Address 1 is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressLine2Controller,
                decoration: InputDecoration(
                  labelText: 'Address 2',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Address 2 is required';
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
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal code',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Postal code is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateCodeController,
                decoration: InputDecoration(
                  labelText: 'State code',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'State code is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _countryCodeController,
                decoration: InputDecoration(
                  labelText: 'Country code',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Country code is required';
                  }
                  return null;
                },
              ),
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
                    child: Text('Pick logo'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: handleImageRemove,
                    child: Text('Remove logo'),
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

                      final url =
                          Uri.parse('$backendUrl/api/organization/create');

                      if (selectedImage == null) {
                        return;
                      }

                      var request = http.MultipartRequest('POST', url)
                        ..files.add(await http.MultipartFile.fromPath(
                            'file', selectedImage!.path))
                        ..fields['name'] = _nameController.text
                        ..fields['type'] = _typeController.text
                        ..fields['email'] = _emailController.text
                        ..fields['phoneNumber'] = _phoneNumberController.text
                        ..fields['addressLine1'] = _addressLine1Controller.text
                        ..fields['addressLine2'] = _addressLine2Controller.text
                        ..fields['city'] = _cityController.text
                        ..fields['postalCode'] = _postalCodeController.text
                        ..fields['countryCode'] = _countryCodeController.text
                        ..fields['stateCode'] = _stateCodeController.text
                        ..headers.addAll({
                          "Authorization": "Bearer $accessToken",
                        });

                      print('cooked request!');
                      final response = await request.send();
                      print('response time....');

                      if (response.statusCode == 201) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('organization Uploaded'),
                              content: const Text(
                                  'Your organization has been uploaded successfully!'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    // Add logic to delete the organization
                                    Navigator.popAndPushNamed(
                                        context, CreateOrganization.id);
                                    Navigator.pushNamed(
                                        context, WelcomeScreen.id);
                                  },
                                  child: const Text('View Feed'),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (response.statusCode == 401 ||
                          response.statusCode == 403) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => LoginScreen(),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('organization Uploaded'),
                              content:
                                  Text('Please complete your profile first'),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () {
                                    // Add logic to delete the organization
                                    Navigator.popAndPushNamed(
                                        context, CreateOrganization.id);
                                  },
                                  child: Text('View Feed'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                    ;
                  }
                },
                child: Text('Create Organization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
