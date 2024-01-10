
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:carousel_slider/carousel_slider.dart';





String formatTimestamp(String timestamp) {
  final DateTime dateTime = DateTime.parse(timestamp);
  final Duration difference = DateTime.now().difference(dateTime);
  final int minutes = difference.inMinutes;

  if (minutes < 1) {
    return 'just now';
  } else if (minutes == 1) {
    return '1 min ago';
  } else if (minutes < 60) {
    return '$minutes mins ago';
  } else {
    final int hours = minutes ~/ 60;
    if (hours == 1) {
      return '1 hour ago';
    } else if (hours < 24) {
      return '$hours hours ago';
    } else {
      final int days = hours ~/ 24;
      if (days == 1) {
        return '1 day ago';
      } else {
        return '$days days ago';
      }
    }
  }
}


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
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
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


class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  Map<String, dynamic> countData = {
    '_count': {
      'posts': 0,
      'comments': 0,
      'upvotes': 0,
      'feedbacks': 0,
    }
  };
  

  final List<String> carouselImages = [
    'data:image/jpeg;base64,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',
    'data:image/jpeg;base64,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',
    'data:image/jpeg;base64,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',
    // Add more image URLs here
  ];

  int _currentIndex = 0;    

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

    Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      
      final String apiUrl = "$backendUrl/api/user/activity/count";
      
        try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            print(jsonData);
            setState(() {
            countData = jsonData;
            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: actionBarRow(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Divider and space below app bar
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Divider(height: 1, thickness: 1, color: Colors.grey),
            SizedBox(height: 10),

            

            // Image Carousel Slider
            CarouselSlider(
              items: carouselImages.map((url) {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                );
              }).toList(),
              options: CarouselOptions(
                height: 200, // Adjust the height as needed
                viewportFraction: 1.0,
                autoPlay: true, // Enable auto-play
                autoPlayInterval: Duration(seconds: 3), // Set auto-play interval
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            // Divider and space below app bar
           
            

            SizedBox(height: 10),
            // Indicator for the current image

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: carouselImages.map((url) {
                int index = carouselImages.indexOf(url);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.blue : Colors.grey,
                  ),
                );
              }).toList(),
            ),
            Text(
              'All Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Count Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CountCard(
                  title: 'Posts',
                  count: countData['_count']['posts'] ?? 0,
                  icon: Icons.description,
                  color: Colors.blue,
                ),
                CountCard(
                  title: 'Comments',
                  count: countData['_count']['comments'] ?? 0,
                  icon: Icons.comment,
                  color: Colors.green,
                ),
                CountCard(
                  title: 'Upvotes',
                  count: countData['_count']['upvotes'] ?? 0,
                  icon: Icons.thumb_up,
                  color: Colors.orange,
                ),
                CountCard(
                  title: 'Feedbacks',
                  count: countData['_count']['feedbacks'] ?? 0,
                  icon: Icons.feedback,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


