import 'dart:convert';

import 'package:ccw/consts/env.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedCard.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/organization/addUserPopup.dart';
import 'package:ccw/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  CountCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            // SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            // SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

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
      open: json['open'] as int,
      inprogress: json['inprogress'] as int,
      inreview: json['inreview'] as int,
      resolved: json['resolved'] as int,
      reopen: json['reopen'] as int,
      onhold: json['onhold'] as int,
      invalid: json['invalid'] as int,
      blocked: json['blocked'] as int,
      isOrganizationUser: json['isOrganizationUser'] as bool,
      users: usersList, // Assign the extracted users list
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

class OrganizationDetailScreen extends StatefulWidget {
  final int organizationId;

  OrganizationDetailScreen({required this.organizationId});

  @override
  _OrganizationDetailScreenState createState() =>
      _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends State<OrganizationDetailScreen> {
  bool _showContactInfo = false;
  bool _showAddressDetails = false;
  late Future<Organization> organizationFuture;

  @override
  void initState() {
    super.initState();
    organizationFuture = fetchOrganization(widget.organizationId);
    setState(() {
      organizationFuture = organizationFuture;
    });
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
        print(org);
        print('done');
        return Organization.fromJson(data);
      } else {
        throw Exception('Failed to load organizations');
      }
    }
    throw Exception('User info not available');
  }

  @override
  Widget build(BuildContext context) {
    bool isOrgManagerLoggedIn =
        Provider.of<UserProvider>(context).isOrgManagerLoggedIn;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: actionBarRow(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: organizationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading organization'));
          } else {
            Organization organization = snapshot.data as Organization;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                      Center(
                        child: FutureBuilder<String>(
                          future: getPublicUrlForFile(organization.logo),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // Display a loading indicator while waiting for the result
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // Display an error message if there's an error
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              // Use the public URL to display the image
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(snapshot.data!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            } else {
                              // Display a placeholder or default image
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 50.0,
                                child:
                                    Icon(Icons.business, color: Colors.white),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.solidBuilding,
                                        size: 20,
                                        color: Colors
                                            .teal, // Customize the color as needed
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        organization.name,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.solidUser,
                                        size: 16,
                                        color: Colors
                                            .teal, // Customize the color as needed
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        organization.type,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.email,
                                        color: Colors.teal,
                                      ),
                                      SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _showContactInfo =
                                                !_showContactInfo;
                                          });
                                        },
                                        child: Text(organization.email),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.teal,
                                      ),
                                      SizedBox(width: 8),
                                      Text(organization.phoneNumber),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                      Divider(height: 5, thickness: 1, color: Colors.grey),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${organization.addressLine1} ${organization.addressLine2}\n${organization.city}, ${organization.stateCode} ${organization.postalCode}\n${organization.countryCode}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(
                                  height: 10, thickness: 1, color: Colors.grey),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: CountCard(
                                      title: 'Open',
                                      count: organization.open ?? 0,
                                      icon: Icons.description,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'Active',
                                      count: organization.inprogress ?? 0,
                                      icon: Icons
                                          .timer, // Assuming timer icon represents in progress
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'On Hold',
                                      count: organization.onhold ?? 0,
                                      icon: Icons.pause_circle_filled,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'Resolved',
                                      count: organization.resolved ?? 0,
                                      icon: Icons.check_circle,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: CountCard(
                                      title: 'In Review',
                                      count: organization.inreview ?? 0,
                                      icon: Icons.rate_review,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'Reopen',
                                      count: organization.reopen ?? 0,
                                      icon: Icons.refresh,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'Invalid',
                                      count: organization.invalid ?? 0,
                                      icon: Icons.thumb_down,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  Expanded(
                                    child: CountCard(
                                      title: 'Blocked',
                                      count: organization.blocked ?? 0,
                                      icon: Icons.block,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
