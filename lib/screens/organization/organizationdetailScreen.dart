import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';

import 'listorganizationscreen.dart';

class OrganizationDetailScreen extends StatelessWidget {
  final Organization organization;

  OrganizationDetailScreen({required this.organization});

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
              'assets/images/ccw-logo.png',
              width: 250,
              height: 250,
              ),
          SizedBox(height: 16),
          Text('Name: ${organization.name}'),
          Text('City: ${organization.city}'),
          // Add more organization details here
        ],
      ),
    );
  }
}
