import 'dart:convert';
import 'package:ccw/consts/env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String email;
  final DateTime timestamp;

  User({
    required this.id,
    required this.email,
    required this.timestamp,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class AddUserPopup extends StatefulWidget {
  final int organizationId;

  AddUserPopup({required this.organizationId});

  @override
  _AddUserPopupState createState() => _AddUserPopupState();
}

class _AddUserPopupState extends State<AddUserPopup> {
  List<User> users = [];
  List<String> roles = ['ADMIN', 'MODERATOR', 'VIEWER'];
  User? selectedUser;
  String? selectedRole;

  Future<bool> addUserOrganizationRelation() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
      var headers = {
        "Authorization": "Bearer $accessToken",
      };

      final response = await http.post(
          Uri.parse('$backendUrl/api/organization/${widget.organizationId}/users'),
          body: {
            "userEmail": selectedUser?.email,
            "role": selectedRole
          },
          headers: headers);
    
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return true;
      
      }
    
    }

    return false;
  }

  Future<void> fetchOrganizationUsers(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer $accessToken",
      };

      final response = await http.get(
          Uri.parse('$backendUrl/api/organization/$id/users?inroledUser=false'),
          headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          users = data.map<User>((json) => User.fromJson(json)).toList();
        });

        return;
      } else {
        throw Exception('Failed to load organizations');
      }
    }
    throw Exception('User info not available');
  }

  @override
  void initState() {
    super.initState();
    fetchOrganizationUsers(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User List Dropdown
          Text('add user popupp'),
          DropdownButton<User>(
            value: selectedUser,
            onChanged: (User? newValue) {
              setState(() {
                selectedUser = newValue;
              });
            },
            items: users.map((User user) {
              return DropdownMenuItem<User>(
                value: user,
                child: Text(user.email),
              );
            }).toList(),
          ),
          Text('role'),
          DropdownButton<String>(
            value: selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                selectedRole = newValue;
              });
            },
            items: roles.map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
          ),

          SizedBox(height: 16),

          // Role Dropdown
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Close the dialog
          },
          child: Text('Cancle'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Add your logic to handle the selected user and role
            print(selectedRole);
            print(selectedUser);

            bool result = await addUserOrganizationRelation();
            print(result);

            Navigator.of(context).pop(result); // Close the dialog
          },
          child: Text('Add User'),
        ),
      ],
    );
  }
}
