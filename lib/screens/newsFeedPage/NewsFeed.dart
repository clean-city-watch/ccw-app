import 'package:ccw/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/postpage/postdetail_page.dart';
import 'package:ccw/screens/newsFeedPage/widgets/category_list.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/newsFeedPage/FeedLatestArticle.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NewsFeed extends StatefulWidget {
  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List feedList = [];
  bool isVisible = false;
  List<Widget> newsFeedWidgetList = [];
  int pageSize = 3; // Set your desired page size
  int pageOffset = 0; // Initialize the page offset
  bool isLoading = false; // Variable to track if new data is loading

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

      var url = Uri.parse(
          "$backendUrl/api/post/filtered-posts?pageSize=$pageSize&pageOffset=$pageOffset&userId=$currentUserId");

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['content'];

        setState(() {
          feedList.addAll(content.map((json) {
            if (json['type'] == 'QUESTION') {
              print("call the Question addition item here...");
            }
            if (json['type'] == 'ISSUE' || json['type'] == 'POST') {
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
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  // topSpace(),
                  searchTextField(),
                  // topSpace(),
                  Container(height: 55, child: CategoryList()),
                ],
              ),
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
