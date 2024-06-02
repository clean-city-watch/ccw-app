import 'package:ccw/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/postpage/postdetail_page.dart';
import 'package:ccw/screens/newsFeedPage/widgets/category_list.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/newsFeedPage/FeedLatestArticle.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrganizationIssue extends StatefulWidget {
  final int organizationId;
  final String PostType;

  OrganizationIssue({required this.organizationId, required this.PostType});

  @override
  State<OrganizationIssue> createState() => _OrganizationIssueState();
}

class _OrganizationIssueState extends State<OrganizationIssue> {
  List feedList = [];
  bool isVisible = false;
  List<Widget> newsFeedWidgetList = [];
  int pageSize = 3; // Set your desired page size
  int pageOffset = 0; // Initialize the page offset
  bool isLoading = false; // Variable to track if new data is loading

  int issueCount = 0;

  @override
  void initState() {
    super.initState();
    // Call the routing function when the widget is initialized
    _getPosts();
  }

  Future<void> _getPosts() async {
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

      print("calling filter post api with type post");
      print("with post type");
      print(widget.PostType);
      print(widget.organizationId);

      var url1 = Uri.parse(
          "$backendUrl/api/organization/${widget.organizationId}/issues");

      var response1 = await http.get(url1, headers: headers);

      if (response1.statusCode == 200) {
        final jsonResponse = jsonDecode(response1.body);
        final content = jsonResponse;

        setState(() {
          issueCount = content; // Increment the page offset for the next page
        });
      }

      var url = Uri.parse(
          "$backendUrl/api/post/filtered-posts?pageSize=$pageSize&pageOffset=$pageOffset&userId=$currentUserId&type=${widget.PostType}&organizationId=${widget.organizationId}");

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['content'];

        setState(() {
          // Clear existing posts before adding new ones
          newsFeedWidgetList.clear();

          feedList.addAll(content.map((json) {
            if (json['type'] == 'QUESTION') {
              print("call the Question addition item here...");
            }
            if (json['type'] == 'ISSUE') {
              newsFeedWidgetList
                  .add(feedNewsCardItem(context, GptFeed.fromJson(json)));
              newsFeedWidgetList.add(topSpace());
              return GptFeed.fromJson(json);
            }

            if (json['type'] == 'POST') {
              newsFeedWidgetList
                  .add(feedNewsCardItem(context, GptFeed.fromJson(json)));
              newsFeedWidgetList.add(topSpace());
              return GptFeed.fromJson(json);
            }
          }).toList());

          isVisible = true;
          isLoading = false;
          pageOffset += 1; // Increment the page offset for the next page
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // add issue button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.users,
                      size: 20,
                      color: Colors.blue, // Customize the color as needed
                    ),
                    SizedBox(width: 8), // Add spacing between icon and text
                    Text(
                      'Issues: $issueCount',
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // organization.isOrganizationUser
                //     ? ElevatedButton(
                //         onPressed: () async {
                //           print('add issue clicked..!');
                //           final result = await showDialog(
                //             context: context,
                //             builder: (BuildContext context) {
                //               return AddUserPopup(
                //                   organizationId: widget.organizationId);
                //             },
                //           );

                //           // Perform the refresh logic here
                //           organizationFuture =
                //               fetchOrganization(widget.organizationId);
                //           setState(() {
                //             organizationFuture = organizationFuture;
                //           });
                //           print('Refreshing...');
                //         },
                //         child: Text('Add User'),
                //       )
                //     : Container(),
              ],
            ),

            Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _getPosts(); // Fetch more data when scrolled to the bottom
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: newsFeedWidgetList.length +
                        1, // +1 for loading indicator
                    itemBuilder: (BuildContext context, int index) {
                      if (index < newsFeedWidgetList.length) {
                        return newsFeedWidgetList[index];
                      } else {
                        if (isLoading) {
                          return CircularProgressIndicator(); // Show a loading indicator
                        } else {
                          return SizedBox(); // Return an empty container when there's no more data
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
