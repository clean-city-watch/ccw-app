import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboardData;

  LeaderboardWidget(this.leaderboardData);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        leaderboardData.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: leaderboardData.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final user = leaderboardData[index];
                  final medal =
                      index < 3 ? ['🥇', '🥈', '🥉'][index] : '${index + 1}';
                  return ListTile(
                    leading: Text(
                      medal,
                      style: TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      '${user['profile']['firstName']} ${user['profile']['LastName']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userInfo = prefs.getString('userinfo');

      if (userInfo != null) {
        Map<String, dynamic> userInfoMap = json.decode(userInfo);
        String accessToken = userInfoMap['access_token'];

        var headers = {
          "Authorization": "Bearer ${accessToken}",
        };

        print('$backendUrl/api/leadboard');
        final response = await http.get(Uri.parse('$backendUrl/api/leadboard'),
            headers: headers);
        print(response.body);
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          setState(() {
            leaderboardData = List<Map<String, dynamic>>.from(jsonData);
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
      }
    } catch (error) {
      // Handle any exceptions that occur
      print('Error fetching data: $error');
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            LeaderboardWidget(leaderboardData),
          ],
        ),
      ),
    );
  }
}
