import 'dart:convert';

import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/user_provider.dart';
import 'package:flutter/material.dart';
import 'organizationdetailScreen.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';


class Organization {
  final int id;
  final String name;
  final String type;
  final String email;
  final String phoneNumber;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String postalCode;
  final String stateCode;
  final String countryCode;
  final String logo;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
    required this.phoneNumber,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.postalCode,
    required this.stateCode,
    required this.countryCode,
    required this.logo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      stateCode: json['stateCode'] as String,
      countryCode: json['countryCode'] as String,
      logo: json['logo'] as String,
    );
  }
}


Future<List<Organization>> fetchOrganizations(bool isUserLoggedIn, bool isOrgManagerLoggedIn) async {

      final prefs = await SharedPreferences.getInstance();
      String? userInfo = prefs.getString('userinfo');

      if(userInfo != null) {
          Map<String, dynamic> userInfoMap = json.decode(userInfo);
          String accessToken = userInfoMap['access_token'];
    
          var headers = {
            "Authorization": "Bearer ${accessToken}",
          };
      
      
          final response = await http.get(Uri.parse('$backendUrl/api/organization'),headers: headers);
          print(response.body);

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            return data.map((json) => Organization.fromJson(json)).toList();
          } else {
            throw Exception('Failed to load organizations');
          }
      }
      return [];
}



class OrganizationCard extends StatelessWidget {
  final Organization organization;

  OrganizationCard({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrganizationDetailScreen(organizationId: organization.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(organization.logo),
              radius: 50.0,
            ),
            SizedBox(height: 16.0),
            Text(
              organization.name,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              organization.city,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isUserLoggedIn = Provider.of<UserProvider>(context).isUserLoggedIn;
    bool isOrgManagerLoggedIn = Provider.of<UserProvider>(context).isOrgManagerLoggedIn;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: actionBarRow(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Organization>>(
        future: fetchOrganizations(isUserLoggedIn, isOrgManagerLoggedIn),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return Center(
              child: Text('No organizations found.'),
            );
          } else {
            final organizations = snapshot.data!;
            return GridView.count(
              crossAxisCount: 2,
              children: organizations.map((organization) => OrganizationCard(organization: organization)).toList(),
            );
          }
        },
      ),
    );
  }
}