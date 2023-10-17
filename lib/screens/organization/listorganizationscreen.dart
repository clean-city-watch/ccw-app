import 'dart:convert';

import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'organizationdetailScreen.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;

class Organization {
  final int id;
  final String name;
  final String city;
  final String logo;

  Organization({
    required this.id,
    required this.name,
    required this.city,
    required this.logo,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      logo: json['logo'] as String,
    );
  }
}


Future<List<Organization>> fetchOrganizations() async {
  final response = await http.get(Uri.parse('$backendUrl/api/organization'));
  print(response.body);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Organization.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load organizations');
  }
}




class OrganizationListScreen extends StatelessWidget {
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
      body: FutureBuilder<List<Organization>>(
        future: fetchOrganizations(),
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
            return ListView.builder(
              itemCount: organizations.length,
              itemBuilder: (context, index) {
                final organization = organizations[index];
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => OrganizationDetailScreen(organization: organization),
                      ),
                    );
                  },
                  leading: Icon(Icons.business),
                  title: Text(organization.name),
                  subtitle: Text(organization.city),
                );
              },
            );
          }
        },
      ),
    );
  }
}

