import 'dart:convert';

import 'package:ccw/consts/env.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/organization/changeIssueStatus.dart';
import 'package:ccw/screens/organization/createPostScreen.dart';
import 'package:ccw/screens/organization/onboardIssuePopup.dart';
import 'package:ccw/screens/organization/organizationIssueScreen.dart';
import 'package:ccw/screens/organization/organizationPostsScreen.dart';
import 'package:ccw/screens/organization/organizationUserWidget.dart';
import 'package:ccw/screens/organization/organizationdetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrganizationNavigation extends StatefulWidget {
  final int organizationId;

  const OrganizationNavigation({required this.organizationId});

  @override
  State<OrganizationNavigation> createState() => _OrganizationNavigationState();
}

class _OrganizationNavigationState extends State<OrganizationNavigation> {
  int _selectedDrawerIndex = 0;
  bool isLoading = false;
  bool isPermission = false;

  List<MenuModel> bottomMenuItems = <MenuModel>[
    new MenuModel(
        'Create Post', 'Share thoughts with the community', Icons.colorize),
    new MenuModel(
        'Onboard Issue', 'Add new issue into organization', Icons.colorize),
    new MenuModel('Change Status', 'Change status for issue', Icons.colorize)
  ];

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  _getUserPermission() async {
    if (isLoading) {
      return; // Prevent multiple simultaneous requests
    }

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);

      String currentUserId = userInfoMap['id'];
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer ${accessToken}",
        "Content-Type":
            "application/json", // Adjust as per your API requirements
      };

      var url = Uri.parse(
          "$backendUrl/api/organization/${widget.organizationId}/users/$currentUserId/permission");

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse;

        print("is user permisiosn");
        print(content);

        setState(() {
          isPermission = content;
        });
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['content'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => LoginScreen(),
          ),
        );
      }
    }
  }

  _selectedTab(int pos) {
    setState(() {
      _onSelectItem(pos);
    });

    switch (pos) {
      case 0:
        // return DashboardWidget();
        return OrganizationDetailScreen(organizationId: widget.organizationId);

      case 1:
        return OrganizationPosts(
            organizationId: widget.organizationId, PostType: 'POST');

      case 2:
        return OrganizationUsers(organizationId: widget.organizationId);

      case 3:
        return OrganizationIssue(
          organizationId: widget.organizationId,
          PostType: 'ISSUE',
        );

      default:
        return const Text("Invalid screen requested");
    }
  }

  @override
  void initState() {
    super.initState();

    _getUserPermission();
    _selectedTab(_selectedDrawerIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedTab(_selectedDrawerIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Post',
        splashColor: Colors.teal,
        onPressed: _modalBottomSheetMenu,
        child: Icon(CupertinoIcons.add),
        elevation: 0,
        shape: CircleBorder(),
      ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        backgroundColor: (Colors.white),
        color: Theme.of(context).primaryColor,
        selectedColor: Colors.teal,
        notchedShape: CircularNotchedRectangle(),
        iconSize: 20.0,
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons
                  .circleInfo, // Use info circle icon for "Details"
              text: 'Details'),
          FABBottomAppBarItem(
              iconData:
                  FontAwesomeIcons.newspaper, // Use newspaper icon for "Posts"
              text: 'Posts'),
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons.users, // Use users icon for "Users"
              text: 'Users'),
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons
                  .circleExclamation, // Use exclamation circle icon for "Issues"
              text: 'Issues'),
        ],
      ),
    );
  }

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 440.0,
            color: Theme.of(context).primaryColor,
            child: Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: new BoxDecoration(
                      color: Colors.white, //Color(0xFF737373),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: ListView.builder(
                      itemCount: bottomMenuItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.teal[100],
                            ),
                            child: Icon(
                              bottomMenuItems[index].icon,
                              color: Colors.teal,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          title: Text(
                            bottomMenuItems[index].title,
                            style: TextStyle(color: Colors.teal, fontSize: 18),
                          ),
                          subtitle: Text(bottomMenuItems[index].subtitle),
                          onTap: () {
                            Navigator.pop(context);
                            debugPrint(bottomMenuItems[index].title);
                            debugPrint('$index');
                            switch (index) {
                              case 0:
                                Navigator.pushNamed(
                                    context, CreateOrganizationPosts.id);
                              case 1:
                                final result = showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return OnboardIssuePopup(
                                        organizationId: widget.organizationId);
                                  },
                                );

                              case 2:
                                final result = showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ChangeIssueStatus(
                                        organizationId: widget.organizationId);
                                  },
                                );
                              default:
                                debugPrint(bottomMenuItems[index].title);
                            }
                          },
                        );
                      }),
                ),

                //SizedBox(height: 10),

                Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            size: 25, color: Colors.grey[900]))),
              ],
            ),
          );
        });
  }
}

class MenuModel {
  String title;
  String subtitle;
  IconData icon;

  MenuModel(this.title, this.subtitle, this.icon);
}
