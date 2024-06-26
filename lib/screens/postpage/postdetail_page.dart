import 'package:ccw/components/components.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/profile/edit_profile.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/postpage/widgets.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedCard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccw/screens/newsFeedPage/widgets/ThumsUpReactions.dart';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PostPageDetails extends StatefulWidget {
  final GptFeed feed;

  PostPageDetails({required this.feed});

  @override
  _PostPageDetailsState createState() => _PostPageDetailsState();
}

class _PostPageDetailsState extends State<PostPageDetails> {
  List commentList = [];
  List<Widget> newsCommentWidgetList = [];
  bool isLoading = false;

  String commentText = '';
  String imageUrl = '';
  String imageUrlResponse = '';

  @override
  void initState() {
    super.initState();
    imageUrl = widget.feed.imageUrl;
    _getImage(widget.feed.imageUrl);
    _getCommentsforPosts();
  }

  _getCommentsforPosts() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (isLoading) {
      return; // Prevent multiple simultaneous requests
    }

    setState(() {
      isLoading = true;
    });

    print('before comment status for request is ');
    // print(widget.feed.status.name);
    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };

      print("userInfo id ");
      var url = Uri.parse('$backendUrl/api/comment/${widget.feed.id}');

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['comments'];

        print(content);
        setState(() {
          commentList = [];
          newsCommentWidgetList = [];
        });

        setState(() {
          commentList.addAll(content.map((json) {
            newsCommentWidgetList.add(topSpace());
            if (json['user']['id'].toString() == userInfoMap['id'].toString()) {
              newsCommentWidgetList
                  .add(othersComment(context, GptComment.fromJson(json), true));
            } else {
              newsCommentWidgetList.add(
                  othersComment(context, GptComment.fromJson(json), false));
            }

            return GptComment.fromJson(json);
          }).toList());

          isLoading = false;
          commentText = '';
        });
      }
    }
  }

  Future<void> _getImage(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

    if (userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];

      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };

      final response = await http.get(
          Uri.parse('$backendUrl/api/minio/covers/$fileName'),
          headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          imageUrlResponse = responseData['imageUrl'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildMessageComposer() {
      final GptFeed feed = widget.feed;
      print(feed.id);

      //TODO: need refactoring here..

      Future<void> postComment(String text) async {
        final prefs = await SharedPreferences.getInstance();
        String? userInfo = prefs.getString('userinfo');

        if (userInfo != null) {
          Map<String, dynamic> userInfoMap = json.decode(userInfo);
          String accessToken = userInfoMap['access_token'];

          var headers = {
            "Authorization": "Bearer ${accessToken}",
          };

          print(feed.id);
          print(userInfoMap['id']);
          print("now adding comment.. for feedid ");
          print(feed.id);

          final url = Uri.parse(
              '$backendUrl/api/comment'); // Replace with your API endpoint

          final response = await http.post(
            url,
            headers: headers,
            body: {
              'postId': feed.id.toString(),
              'content': text,
            },
          );

          if (response.statusCode == 201) {
            // Comment successfully posted, you can handle the response accordingly
            print('Comment posted successfully');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Comment Upload'),
                  content: Text('Comment posted successfully!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        _getCommentsforPosts();
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Add logic to delete the post
                        print('call delete post api here...');
                        _getCommentsforPosts();
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('View'),
                    ),
                  ],
                );
              },
            );
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
            // Handle the error if the request fails
            print('Failed to post comment');
          }
        }
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: 70.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0), // Add rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2), // Subtle shadow for depth
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.emoji_people), // More engaging "Add people" icon
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                // Implement functionality to add emojis or stickers (optional)
              },
            ),
            Expanded(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  setState(() {
                    commentText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText:
                      "Share your thoughts...", // Clearer placeholder text
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.7), // Faded hint color
                  ),
                  border: InputBorder
                      .none, // Remove default border for cleaner look
                ),
                style: TextStyle(
                  // Customize text style for better readability
                  fontSize: 16.0,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                if (commentText.isNotEmpty) {
                  print(commentText);
                  postComment(commentText);
                  setState(() {
                    commentText = "";
                  });
                }
              },
            ),
          ],
        ),
      );
    }

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
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // feedNewsCardItem(context,widget.feed),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: Colors.grey,
                          width: 0.5)),
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          renderCategoryTime(widget.feed),
                          space10(),
                          userAvatarSection(context, widget.feed),
                          space15(),
                          Visibility(
                              visible: widget.feed.title.isEmpty == true
                                  ? false
                                  : true,
                              child: Text(widget.feed.title,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                          space15(),
                          Visibility(
                              visible: widget.feed.content.isEmpty == true
                                  ? false
                                  : true,
                              child: Text(widget.feed.content,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColor))),
                          space15(),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: imageUrl != "null"
                                          ? PhotoViewGallery.builder(
                                              itemCount: 1,
                                              builder: (context, index) {
                                                return PhotoViewGalleryPageOptions(
                                                  imageProvider: NetworkImage(
                                                      imageUrlResponse),
                                                  minScale:
                                                      PhotoViewComputedScale
                                                          .contained,
                                                  maxScale:
                                                      PhotoViewComputedScale
                                                              .covered *
                                                          2,
                                                  heroAttributes:
                                                      PhotoViewHeroAttributes(
                                                          tag: 'imageTag'),
                                                );
                                              },
                                              scrollPhysics:
                                                  BouncingScrollPhysics(),
                                              backgroundDecoration:
                                                  BoxDecoration(
                                                color: Colors.black,
                                              ),
                                            )
                                          : Center(
                                              child: Text('No image available'),
                                            ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: imageUrl != "null"
                                ? Image.network(
                                    imageUrlResponse,
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                          // imageCarouselSlider(),

                          space15(),
                          setLocation(context, widget.feed),
                          Divider(thickness: 1),
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.addressBook),
                              SizedBox(width: 10),
                              Text(
                                '${widget.feed.count.upvotes} Members supported the post',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                          Divider(thickness: 1),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    print('FB Reactions Tapped');
                                    FbReactionBox();
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.thumbsUp,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text('${widget.feed.count.upvotes}')
                                    ],
                                  )),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () =>
                                            print("comment section printed.."),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons.comment,
                                                size: 18),
                                            SizedBox(width: 5),
                                            Text(
                                                '${widget.feed.count.comments}')
                                          ],
                                        ))
                                  ]),
                              Icon(FontAwesomeIcons.bookmark, size: 18),
                              GestureDetector(
                                  onTap: () {
                                    print('share code');
                                  },
                                  child:
                                      Icon(FontAwesomeIcons.shareAlt, size: 18))
                            ],
                          ),
                          space15(),
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: newsCommentWidgetList.map((widget) {
                    return Column(
                      children: [
                        // SizedBox(height: 30),
                        widget,
                      ],
                    );
                  }).toList(),
                ),

                topSpace(),

                _buildMessageComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
