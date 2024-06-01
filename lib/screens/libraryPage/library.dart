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

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Map<String, dynamic> countData = {
    '_count': {
      'posts': 0,
      'comments': 0,
      'upvotes': 0,
      'feedbacks': 0,
    }
  };
  List feedList = [];
  bool isVisible = false;
  List<Widget> newsFeedWidgetList = [];
  int pageSize = 4; // Set your desired page size
  int pageOffset = 0; // Initialize the page offset
  bool isLoading = false; // Variable to track if new data is loading

  @override
  void initState() {
    super.initState();
    // Call the routing function when the widget is initialized
    fetchData();
    _getPosts();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);

      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };
      final String apiUrl = "$backendUrl/api/user/activity/count";

      try {
        final response = await http.get(Uri.parse(apiUrl), headers: headers);

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          print(jsonData);
          setState(() {
            countData = jsonData;
          });
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          final jsonResponse = jsonDecode(response.body);
          final content = jsonResponse['content'];

          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => LoginScreen(),
            ),
          );
        } else {
          // Handle error when API request fails
          print('Failed to fetch data: ${response.statusCode}');
        }
      } catch (error) {
        // Handle any exceptions that occur
        print('Error fetching data: $error');
      }
    }
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
      print('this is constructed header....');
      print(headers);

      var url = Uri.parse(
          "$backendUrl/api/post/filtered-posts?pageSize=$pageSize&pageOffset=$pageOffset&userId=$currentUserId&self=true");

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['content'];

        setState(() {
          feedList.addAll(content.map((json) {
            print('upvotes are: ');
            print(json['upvotes'].length);
            newsFeedWidgetList
                .add(feedLibraryCardItem(context, GptFeed.fromJson(json)));
            newsFeedWidgetList.add(topSpace());
            return GptFeed.fromJson(json);
          }).toList());

          isVisible = true;
          isLoading = false;
          pageOffset += 1; // Increment the page offset for the next page
        });
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
            // Text(
            //   'All Activities',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // Count Cards

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CountCard(
                    title: 'Posts',
                    count: countData['_count']['posts'] ?? 0,
                    icon: Icons.description,
                    color: Colors.teal,
                  ),
                ),
                Expanded(
                  child: CountCard(
                    title: 'Comments',
                    count: countData['_count']['comments'] ?? 0,
                    icon: Icons.comment,
                    color: Colors.teal,
                  ),
                ),
                Expanded(
                  child: CountCard(
                    title: 'Upvotes',
                    count: countData['_count']['upvotes'] ?? 0,
                    icon: Icons.thumb_up,
                    color: Colors.teal,
                  ),
                ),
                Expanded(
                  child: CountCard(
                    title: 'Feedback',
                    count: countData['_count']['feedbacks'] ?? 0,
                    icon: Icons.feedback,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
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
