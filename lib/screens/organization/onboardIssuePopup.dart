import 'dart:convert';
import 'package:ccw/consts/env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardIssuePopup extends StatefulWidget {
  final int organizationId;

  OnboardIssuePopup({required this.organizationId});

  @override
  _OnboardIssuePopupState createState() => _OnboardIssuePopupState();
}

class _OnboardIssuePopupState extends State<OnboardIssuePopup> {
  String? issueNumber;

  Future<bool> addissueOrganizationRelation() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
      var headers = {
        "Authorization": "Bearer $accessToken",
      };

      final response = await http.post(
        Uri.parse(
            '$backendUrl/api/organization/${widget.organizationId}/issue'),
        body: {
          "issueNumber": issueNumber,
        },
        headers: headers,
      );

      print(response);
      print('printitng repsone.');
      print(response.statusCode);
      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        return true;
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Onboard issue'),
      content: Container(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // User List Dropdown
            Container(
              width: 200, // Adjust width as needed
              child: TextField(
                onChanged: (String newValue) {
                  setState(() {
                    issueNumber = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Enter issue number',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 5), // Adjust padding if needed
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            bool result = await addissueOrganizationRelation();
            print(result);
            Navigator.of(context).pop(result); // Close the dialog
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
