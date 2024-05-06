import 'dart:convert';

import 'package:ccw/consts/env.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/organization/addUserPopup.dart';
import 'package:ccw/screens/organization/listorganizationscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  final int open;
  final int inprogress;
  final int inreview;
  final int resolved;
  final int reopen;
  final int onhold;
  final int invalid;
  final int blocked;
  final bool isOrganizationUser;
  final List<User>? users; // Make the List of users optional

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
    required this.open,
    required this.inprogress,
    required this.inreview,
    required this.resolved,
    required this.reopen,
    required this.onhold,
    required this.invalid,
    required this.blocked,
    required this.isOrganizationUser,
    this.users, // Mark the List of users as optional
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    // Extract users list from the JSON if it exists
    List<User>? usersList;
    if (json['users'] != null) {
      usersList = List<User>.from(
          json['users'].map((user) => User.fromJson(user['user'])));
    }

    return Organization(
      id: json['id'] as int ?? 0,
      name: json['name'] as String ?? '',
      type: json['type'] as String ?? '',
      email: json['email'] as String ?? '',
      phoneNumber: json['phoneNumber'] as String ?? '',
      addressLine1: json['addressLine1'] as String ?? '',
      addressLine2: json['addressLine2'] as String ?? '',
      city: json['city'] as String ?? '',
      postalCode: json['postalCode'] as String ?? '',
      stateCode: json['stateCode'] as String ?? '',
      countryCode: json['countryCode'] as String ?? '',
      logo: json['logo'] as String ?? '',
      open: json['open'] as int ?? 0, // Provide default value 0 for open
      inprogress: json['inprogress'] as int ??
          0, // Provide default value 0 for inprogress
      inreview:
          json['inreview'] as int ?? 0, // Provide default value 0 for inreview
      resolved:
          json['resolved'] as int ?? 0, // Provide default value 0 for resolved
      reopen: json['reopen'] as int ?? 0, // Provide default value 0 for reopen
      onhold: json['onhold'] as int ?? 0, // Provide default value 0 for onhold
      invalid:
          json['invalid'] as int ?? 0, // Provide default value 0 for invalid
      blocked:
          json['blocked'] as int ?? 0, // Provide default value 0 for blocked
      isOrganizationUser: json['isOrganizationUser'] as bool ??
          false, // Provide default value false for isOrganizationUser
      users: usersList ?? [], // Provide default value an empty list for users
    );
  }
}

class User {
  final int id;
  final UserProfile profile;

  User({
    required this.id,
    required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      profile: UserProfile.fromJson(json['profile']),
    );
  }
}

class UserProfile {
  final String firstName;
  final String lastName;
  final String avatar;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['firstName'] as String,
      lastName: json['LastName'] as String,
      avatar: json['avatar'] as String? ?? '',
    );
  }
}

class OrganizationUsers extends StatefulWidget {
  final int organizationId;

  const OrganizationUsers({required this.organizationId});

  @override
  State<OrganizationUsers> createState() => _OrganizationUsersState();
}

class _OrganizationUsersState extends State<OrganizationUsers> {
  late Organization organization = Organization(
    id: 0,
    name: '',
    type: '',
    email: '',
    phoneNumber: '',
    addressLine1: '',
    addressLine2: '',
    city: '',
    postalCode: '',
    stateCode: '',
    countryCode: '',
    logo: '',
    open: 0,
    inprogress: 0,
    inreview: 0,
    resolved: 0,
    reopen: 0,
    onhold: 0,
    invalid: 0,
    blocked: 0,
    isOrganizationUser: false,
    users: [],
  );
  bool _showContactInfo = false;
  bool _showAddressDetails = false;
  late Future<Organization> organizationFuture;

  @override
  void initState() {
    super.initState();
    fetchOrganization(widget.organizationId);
  }

  Future<String> getPublicUrlForAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };
      final avatarUrl = await http.get(
          Uri.parse('$backendUrl/api/minio/covers/${avatar}'),
          headers: headers);
      if (avatarUrl.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(avatarUrl.body);
        return responseData['imageUrl'];
      }
    }

    return "https://www.w3schools.com/w3images/avatar3.png";
  }

  Future<Organization> fetchOrganization(int id) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer $accessToken",
      };

      final response = await http
          .get(Uri.parse('$backendUrl/api/organization/$id'), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        print('decoding start');
        Organization org = Organization.fromJson(data);
        setState(() {
          organization = org;
        });
        return Organization.fromJson(data);
      } else {
        throw Exception('Failed to load organizations');
      }
    }
    throw Exception('User info not available');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack(
            //   children: [
            //     Container(
            //       height: 160,
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //       ),
            //     ),
            //     Center(
            //       child: Container(
            //         margin: EdgeInsets.symmetric(vertical: 20),
            //         width: 120,
            //         height: 120,
            //         decoration: BoxDecoration(
            //           shape: BoxShape.circle,
            //           image: DecorationImage(
            //             image: NetworkImage(organization.logo),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Row(
                //               children: [
                //                 FaIcon(
                //                   FontAwesomeIcons.solidBuilding,
                //                   size: 20,
                //                   color: Colors
                //                       .teal, // Customize the color as needed
                //                 ),
                //                 SizedBox(width: 8),
                //                 Text(
                //                   organization.name,
                //                   style: TextStyle(
                //                     fontSize: 24,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //                 SizedBox(width: 8),
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 FaIcon(
                //                   FontAwesomeIcons.solidUser,
                //                   size: 16,
                //                   color: Colors
                //                       .teal, // Customize the color as needed
                //                 ),
                //                 SizedBox(width: 8),
                //                 Text(
                //                   organization.type,
                //                   style: TextStyle(fontSize: 18),
                //                 ),
                //                 SizedBox(width: 8),
                //               ],
                //             ),
                //           ],
                //         ),
                //         Column(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           children: [
                //             Row(
                //               children: [
                //                 Icon(
                //                   Icons.email,
                //                   color: Colors.teal,
                //                 ),
                //                 SizedBox(width: 8),
                //                 InkWell(
                //                   onTap: () {
                //                     setState(() {
                //                       _showContactInfo = !_showContactInfo;
                //                     });
                //                   },
                //                   child: Text(organization.email),
                //                 ),
                //               ],
                //             ),
                //             SizedBox(height: 8),
                //             Row(
                //               children: [
                //                 Icon(
                //                   Icons.phone,
                //                   color: Colors.teal,
                //                 ),
                //                 SizedBox(width: 8),
                //                 Text(organization.phoneNumber),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //     SizedBox(height: 16),
                //   ],
                // ),
                Divider(height: 5, thickness: 1, color: Colors.grey),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Divider(
                        //     height: 10, thickness: 1, color: Colors.grey),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.users,
                                  size: 20,
                                  color: Colors
                                      .teal, // Customize the color as needed
                                ),
                                SizedBox(
                                    width:
                                        8), // Add spacing between icon and text
                                Text(
                                  'Users: ${organization.users!.length}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            organization.isOrganizationUser
                                ? ElevatedButton(
                                    onPressed: () async {
                                      print('add user clicked..!');
                                      final result = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddUserPopup(
                                              organizationId:
                                                  widget.organizationId);
                                        },
                                      );

                                      // Perform the refresh logic here
                                      organizationFuture = fetchOrganization(
                                          widget.organizationId);
                                      setState(() {
                                        organizationFuture = organizationFuture;
                                      });
                                      print('Refreshing...');
                                    },
                                    child: Text('Add User'),
                                  )
                                : Container(),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: organization.users!.map((user) {
                            return FutureBuilder<String>(
                              future:
                                  getPublicUrlForAvatar(user.profile.avatar),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Return a placeholder or loading indicator while fetching the image URL
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  // Handle errors
                                  return Text('Error loading image');
                                } else {
                                  String imageUrl = snapshot.data ??
                                      'https://www.w3schools.com/w3images/avatar3.png';

                                  return Card(
                                    // margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(imageUrl),
                                      ),
                                      title: Text(
                                          '${user.profile.firstName} ${user.profile.lastName}'),
                                      // Add any additional information here, e.g., email, phone, etc.
                                      // subtitle: Text('${user.profile.email}'),
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
