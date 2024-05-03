import 'dart:convert';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/components/components.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccw/consts/env.dart' show backendUrl;

class UserFeedbackWidget extends StatefulWidget {
  @override
  _UserFeedbackWidgetState createState() => _UserFeedbackWidgetState();
}

class _UserFeedbackWidgetState extends State<UserFeedbackWidget> {
  double _rating = 0;
  TextEditingController _feedbackController = TextEditingController();

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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Rate Your Experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 40.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Share Your Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Handle the submission of feedback
                final double rating = _rating;
                final String feedbackText = _feedbackController.text;

                final prefs = await SharedPreferences.getInstance();
                String? userInfo = prefs.getString('userinfo');

                if (userInfo != null) {
                  Map<String, dynamic> userInfoMap = json.decode(userInfo);
                  String accessToken = userInfoMap['access_token'];

                  var headers = {
                    "Authorization": "Bearer ${accessToken}",
                  };
                  final String apiUrl = '$backendUrl/api/feedback';

                  try {
                    print(rating);
                    print(feedbackText);
                    final response = await http.post(Uri.parse(apiUrl),
                        body: {
                          'rating': rating.toString(),
                          'feedback': feedbackText,
                          'authorId': userInfoMap['id']
                        },
                        headers: headers);

                    if (response.statusCode == 201) {
                      // Profile updated successfully
                      print('Feedback Sent successfully');
                      signUpAlert(
                        onPressed: () async {
                          print('back to the feeds page');
                        },
                        title: 'Feedback Upload',
                        desc: 'Feedback sent successfully!',
                        btnText: 'ok',
                        context: context,
                      ).show();
                    } else if (response.statusCode == 401 ||
                        response.statusCode == 403) {
                      final jsonResponse = jsonDecode(response.body);
                      final content = jsonResponse['content'];

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => LoginScreen(),
                        ),
                      );
                    } else {
                      // Handle other status codes or errors
                      print('Failed to update profile');
                    }
                  } catch (e) {
                    // Handle network errors or exceptions
                    print('Error: $e');
                  }
                }

                // You can now send the rating and feedback to your backend or process it as needed
                print('Rating: $rating');
                print('Feedback: $feedbackText');

                // Optionally, clear the feedback form
                setState(() {
                  _rating = 0;
                  _feedbackController.clear();
                });

                // Show a success message or navigate to another screen
                // Navigator.pop(context); // Navigate back or display a success message
              },
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
