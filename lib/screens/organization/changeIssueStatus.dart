import 'dart:convert';
import 'package:ccw/consts/env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeIssueStatus extends StatefulWidget {
  final int organizationId;

  ChangeIssueStatus({required this.organizationId});

  @override
  _ChangeIssueStatusState createState() => _ChangeIssueStatusState();
}

class _ChangeIssueStatusState extends State<ChangeIssueStatus> {
  String? issueNumber;
  String? selectedStatus;

  List<String> statuses = [
    'Open',
    'In Progress',
    'In Review',
    'Resolved',
    'Reopened',
    'On Hold',
    'Invalid',
    'Blocked'
  ];

  Future<bool> addissueOrganizationRelation() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
      var headers = {
        "Authorization": "Bearer $accessToken",
      };

      final response = await http.patch(
        Uri.parse(
            '$backendUrl/api/organization/${widget.organizationId}/issues'),
        body: {
          "issueNumber": issueNumber,
          "status": selectedStatus,
        },
        headers: headers,
      );

      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
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
      title: Text('Change issue Status'),
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

            SizedBox(height: 16),
            // Role Dropdown
            Container(
              width: 200, // Adjust width as needed
              child: DropdownButtonFormField<String>(
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                items: statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Adjust padding if needed
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
          child: Text('Change'),
        ),
      ],
    );
  }
}
