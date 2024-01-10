import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccw/consts/env.dart' show backendUrl;

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

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
Future<List<dynamic>> fetchMessages() async {
  final prefs = await SharedPreferences.getInstance();
  String? userInfo = prefs.getString('userinfo');
  if (userInfo != null) {
    Map<String, dynamic> userInfoMap = json.decode(userInfo);
    String accessToken = userInfoMap['access_token'];
        
    var headers = {
      "Authorization": "Bearer ${accessToken}",
    };
    final String apiUrl = "$backendUrl/api/user/log";

    final response = await http.get(Uri.parse(apiUrl),headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }
  
  // Return an empty list if userInfo is null or other conditions are not met
  return [];
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
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: fetchMessages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Handle the case where fetchMessages() returns null
                final messages = snapshot.data ?? [];

                // Now you can use the 'messages' list to populate your UI
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Build UI for each message as a Card
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Stack(
                        children: [
                          ListTile(
                            title: Text(
                              message['message'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Text(
                              formatTimestamp(message['timestamp']),
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
