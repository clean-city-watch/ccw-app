import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/ThumsUpReactions.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:ccw/screens/postpage/postdetail_page.dart';
import 'package:ccw/screens/postpage/edit_post.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ccw/screens/servicesPage/routeservice.dart';
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

Future<String> getPublicUrlForFile(String fileName) async {
  final prefs = await SharedPreferences.getInstance();
  String? userInfo = prefs.getString('userinfo');

  if (userInfo != null) {
    Map<String, dynamic> userInfoMap = json.decode(userInfo);
    String accessToken = userInfoMap['access_token'];

    var headers = {
      "Authorization": "Bearer ${accessToken}",
    };
    final avatarUrl = await http.get(
        Uri.parse('$backendUrl/api/minio/covers/$fileName'),
        headers: headers);
    if (avatarUrl.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(avatarUrl.body);
      return responseData['imageUrl'];
    }
  }

  return "https://www.w3schools.com/w3images/avatar3.png";
}

Widget feedCard(BuildContext context, GptFeed listFeed) {
  return Card(
    child: GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PostPageDetails(feed: listFeed))),
      child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              renderCategoryTime(listFeed),
              space10(),
              userAvatarSection(context, listFeed),
              space15(),
              Text(listFeed.title,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              space15(),
              Text(listFeed.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              space15(),
              setLocation(context, listFeed),
              Divider(thickness: 1),
              Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.addressBook),
                  SizedBox(width: 10),
                  Text(
                    '${listFeed.count.upvotes} Members supported the post',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: 10),
              likeCommentShare(context, listFeed),
              space15(),
            ],
          )),
    ),
  );
}

Widget likeCommentShareForAuthor(BuildContext context, GptFeed listFeed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      GestureDetector(
          onTap: () async {
            if (!listFeed.isupvote) {
              // If the user has not upvoted, perform the upvote action
              // Here, you can call your API to upvote and handle the response accordingly

              final prefs = await SharedPreferences.getInstance();
              String? userInfo = prefs.getString('userinfo');
              if (userInfo != null) {
                Map<String, dynamic> userInfoMap = json.decode(userInfo);
                String accessToken = userInfoMap['access_token'];

                var headers = {
                  "Authorization": "Bearer ${accessToken}",
                };
                final String apiUrl = '$backendUrl/api/upvote';

                try {
                  print(listFeed.id);
                  print(userInfoMap['id']);
                  final response = await http.post(Uri.parse(apiUrl),
                      body: {
                        "postId": listFeed.id.toString(),
                      },
                      headers: headers);
                  print('upvote success');

                  if (response.statusCode == 201) {
                    // Profile updated successfully
                    print('upvote added successfully');
                    // listFeed.isupvote =true;
                  } else {
                    // Handle other status codes or errors
                    print('Failed to update profile');
                  }
                } catch (e) {
                  // Handle network errors or exceptions
                  print('Error: $e');
                }
              }
            }
          },
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.thumbsUp,
                size: 18,
                color: listFeed.isupvote
                    ? Colors.blue
                    : Colors.black, // Change color based on upvote status
              ),
              SizedBox(width: 5),
              Text('${listFeed.count.upvotes}')
            ],
          )),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostPageDetails(feed: listFeed))),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.comment, size: 18),
                    SizedBox(width: 5),
                    Text('${listFeed.count.comments}')
                  ],
                ))
          ]),
      GestureDetector(
          onTap: () {
            print('edit Post');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPostWidget(feed: listFeed)));
          },
          child: Icon(FontAwesomeIcons.edit, size: 18)),
      GestureDetector(
          onTap: () {
            print('delete Post');
          },
          child: Icon(FontAwesomeIcons.trashAlt, size: 18)),
      GestureDetector(
          onTap: () {
            print('share code');
          },
          child: Icon(FontAwesomeIcons.shareAlt, size: 18))
    ],
  );
}

Widget likeCommentShare(BuildContext context, GptFeed listFeed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      GestureDetector(
          onTap: () async {
            if (!listFeed.isupvote) {
              // If the user has not upvoted, perform the upvote action
              // Here, you can call your API to upvote and handle the response accordingly

              final prefs = await SharedPreferences.getInstance();
              String? userInfo = prefs.getString('userinfo');
              if (userInfo != null) {
                Map<String, dynamic> userInfoMap = json.decode(userInfo);
                String accessToken = userInfoMap['access_token'];

                var headers = {
                  "Authorization": "Bearer ${accessToken}",
                };
                final String apiUrl = '$backendUrl/api/upvote';

                try {
                  print(listFeed.id);
                  print(userInfoMap['id']);
                  final response = await http.post(Uri.parse(apiUrl),
                      body: {
                        "postId": listFeed.id.toString(),
                      },
                      headers: headers);
                  print('upvote success');

                  if (response.statusCode == 201) {
                    // Profile updated successfully
                    print('upvote added successfully');
                    // listFeed.isupvote =true;
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
            }
          },
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.thumbsUp,
                size: 18,
                color: listFeed.isupvote
                    ? Colors.blue
                    : Colors.black, // Change color based on upvote status
              ),
              SizedBox(width: 5),
              Text('${listFeed.count.upvotes}')
            ],
          )),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PostPageDetails(feed: listFeed))),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.comment, size: 18),
                    SizedBox(width: 5),
                    Text('${listFeed.count.comments}')
                  ],
                ))
          ]),
      Icon(FontAwesomeIcons.bookmark, size: 18),
      GestureDetector(
          onTap: () {
            print('share code');
          },
          child: Icon(FontAwesomeIcons.shareAlt, size: 18))
    ],
  );
}

Widget setLocation(BuildContext context, GptFeed listFeed) {
  return GestureDetector(
    onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RouteServicePage(feed: listFeed))),
    child: Row(
      children: <Widget>[
        Icon(Icons.location_on, color: Colors.teal),
        SizedBox(width: 15),
        Text(
          listFeed.city,
          style: TextStyle(fontSize: 12, color: Colors.teal),
        ),
      ],
    ),
  );
}

Widget userAvatarSection(BuildContext context, GptFeed listFeed) {
  return FutureBuilder<String>(
    future: getPublicUrlForFile(listFeed.author.profile.avatar),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Display a loading indicator while waiting for the result
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        // Display an error message if there's an error
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        // Use the public URL to display the image
        return Row(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: ClipOval(
                          child: Image.network(
                              snapshot.data!), // Use the public URL here
                        ),
                        radius: 20,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                listFeed.author.profile.firstName +
                                    ' ' +
                                    listFeed.author.profile.lastName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'User Description',
                            style: TextStyle(fontSize: 12, color: Colors.teal),
                          ),
                        ],
                      )
                    ],
                  ),
                  moreOptions3Dots(context),
                ],
              ),
            ),
          ],
        );
      } else {
        // Display a placeholder or default image
        return CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 20,
          child: Icon(Icons.person, color: Colors.white),
        );
      }
    },
  );
}

Widget moreOptions3Dots(BuildContext context) {
  return GestureDetector(
    // Just For Demo, Doesn't Work As Needed
    onTap: () =>
        _onCenterBottomMenuOn3DotsPressed(context), //_showPopupMenu(context),
    child: Container(
      child: Icon(FontAwesomeIcons.ellipsisV, size: 18),
    ),
  );
}

Widget space10() {
  return SizedBox(height: 10);
}

Widget space15() {
  return SizedBox(height: 10);
}

Widget getStatusTag(String statusName) {
  Color tagColor;
  String tagLabel;

  switch (statusName) {
    case 'Open':
      tagColor = Colors.green;
      tagLabel = 'Open';
      break;
    case 'In Progress':
      tagColor = Colors.blue;
      tagLabel = 'In Progress';
      break;
    case 'Review':
      tagColor = Colors.orange;
      tagLabel = 'Review';
      break;
    case 'Resolved':
      tagColor = Colors.purple;
      tagLabel = 'Resolved';
      break;
    case 'Reopened':
      tagColor = Colors.red;
      tagLabel = 'Reopened';
      break;
    case 'On Hold':
      tagColor = Colors.yellow;
      tagLabel = 'On Hold';
      break;
    case 'Invalid':
      tagColor = Colors.grey;
      tagLabel = 'Invalid';
      break;
    case 'Blocked':
      tagColor = Colors.black;
      tagLabel = 'Blocked';
      break;
    default:
      tagColor = Colors.grey;
      tagLabel = 'Unknown';
      break;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: tagColor,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      tagLabel,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

Widget renderCategoryTime(GptFeed listFeed) {
  final statusTag = getStatusTag(listFeed.status.name);

  final formattedTime = formatTimestamp(listFeed.timestamp);
  print(formattedTime);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      statusTag,
      Text(formattedTime,
          style: TextStyle(fontSize: 14, color: Colors.grey[700])),
    ],
  );
}

_onCenterBottomMenuOn3DotsPressed(BuildContext context) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF737373),
          child: _buildBottomNavMenu(context),
        );
      });
}

Widget _buildBottomNavMenu(BuildContext context) {
  List<Menu3DotsModel> listMore = [];
  listMore.add(
      Menu3DotsModel('Hide Post', 'See fewer posts like this', Icons.block));
  listMore.add(Menu3DotsModel(
      'Unfollow <username>', 'See fewer posts like this', Icons.person_add));
  listMore.add(
      Menu3DotsModel('Report Post', 'See fewer posts like this', Icons.info));
  listMore.add(Menu3DotsModel(
      'Copy Post link', 'See fewer posts like this', Icons.insert_link));

  return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
      ),
      child: ListView.builder(
          itemCount: listMore.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                listMore[index].title,
                style: TextStyle(fontSize: 18),
              ),
              subtitle: Text(listMore[index].subtitle),
              leading: Icon(
                listMore[index].icons,
                size: 20,
                color: Colors.teal,
              ),
            );
          }));
}

class Menu3DotsModel {
  String title;
  String subtitle;
  IconData icons;

  Menu3DotsModel(this.title, this.subtitle, this.icons);
}
