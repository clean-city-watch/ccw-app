import 'dart:convert';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/components/components.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  String firstName;
  String lastName;
  String phoneNumber;
  String addressLine1;
  String addressLine2;

  Profile({
    required  this.firstName,
    required  this.lastName,
    required  this.phoneNumber,
    required  this.addressLine1,
    required  this.addressLine2,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "LastName": lastName,
      "phoneNumber": phoneNumber,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
    };
  }
}

class EditProfileWidget extends StatefulWidget {
    static String id = 'edit_profile_screen';
  @override
  _EditProfileWidgetState createState() => _EditProfileWidgetState();
}


class _EditProfileWidgetState extends State<EditProfileWidget> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

   if(userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
        
      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };
       print('inside the profile page');
        print(userInfo);
        print('$backendUrl/api/profile/${userInfoMap['id']}');
        final response = await http.get(Uri.parse('$backendUrl/api/profile/${userInfoMap['id']}'),headers: headers);
        if (response.statusCode == 200) {
          final Map<String, dynamic> userData = json.decode(response.body);
          print(userData);

          setState(() {
            firstNameController.text = userData['firstName'] ?? '';
            lastNameController.text = userData['LastName'] ?? '';
            phoneNumberController.text = userData['phoneNumber'] ?? '';
            addressLine1Controller.text = userData['addressLine1'] ?? '';
            addressLine2Controller.text = userData['addressLine2'] ?? '';
          });
        } else {
          throw Exception('Failed to load user profile');
        }
   }



   
  }

  Future<void> _editProfile(Profile profile) async {
    print('inside the edit profile function');
    print(profile);

    // profile['id'] = 1;
    // profile['userId'] = 1;
    final testprofile = profile.toJson();

    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if(userInfo != null){
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      
      testprofile['userId'] = userInfoMap['id'];
      String accessToken = userInfoMap['access_token'];
        
      

      print(testprofile);

      
      final String apiUrl = '$backendUrl/api/profile/edit';
      
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            "Authorization": "Bearer ${accessToken}",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          
          body: jsonEncode(testprofile),
        );

        if (response.statusCode == 202) {
          // Profile updated successfully
          print('Profile updated successfully');
          signUpAlert(
              onPressed: () async {
              print('back to the feeds page');
              Navigator.popAndPushNamed(
                      context, EditProfileWidget.id);
                  Navigator.pushNamed(context, WelcomeScreen.id);
              },
              title: 'Profile Upload',
              desc:
                  'Profile uploaded successfully!',
              btnText: 'Feed Now',
              context: context,
          ).show();
        } else {
          // Handle other status codes or errors
          print('Failed to update profile');
        }
      } catch (e) {
        // Handle network errors or exceptions
        print('Error: $e');
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: addressLine1Controller,
              decoration: InputDecoration(labelText: 'Address Line 1'),
            ),
            TextField(
              controller: addressLine2Controller,
              decoration: InputDecoration(labelText: 'Address Line 2'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                final profile = Profile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  phoneNumber: phoneNumberController.text,
                  addressLine1: addressLine1Controller.text,
                  addressLine2: addressLine2Controller.text,
                );

                print(jsonEncode(profile.toJson()));
                _editProfile(profile);
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
