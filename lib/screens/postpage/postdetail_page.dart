import 'package:ccw/components/components.dart';
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


class PostPageDetails extends StatefulWidget {
   final GptFeed feed;

  PostPageDetails({required this.feed});

  @override
  _PostPageDetailsState createState() => _PostPageDetailsState();
}

class _PostPageDetailsState extends State<PostPageDetails> {
  List commentList = [];
  List<Widget> newsCommentWidgetList=[];
  bool isLoading = false;

  String commentText = '';

  @override
  void initState()  {
    super.initState();
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
    print(widget.feed.status.name);
     if(userInfo != null) {
          Map<String, dynamic> userInfoMap = json.decode(userInfo);
           String accessToken = userInfoMap['access_token'];

           var headers = {
                "Authorization": "Bearer ${accessToken}",
              };

          print("userInfo id ");
          var url = Uri.parse('$backendUrl/api/comment/${widget.feed.id}');

          var response = await http.get(url,headers: headers);
          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            final content = jsonResponse['comments'];

            print(content);

          setState(() {
            commentList.addAll(content.map((json) {
              

              if(json['user']['id'].toString()== userInfoMap['id'].toString()){
                newsCommentWidgetList.add(commentReply(context, GptComment.fromJson(json)));
                newsCommentWidgetList.add(topSpace());
              }else{
                newsCommentWidgetList.add(othersComment(context, GptComment.fromJson(json)));
                newsCommentWidgetList.add(topSpace());
              }
             
              return GptComment.fromJson(json);
            }).toList());

            isLoading = false;
          
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

          if(userInfo != null) {
              Map<String, dynamic> userInfoMap = json.decode(userInfo);
              String accessToken = userInfoMap['access_token'];
        
              var headers = {
                "Authorization": "Bearer ${accessToken}",
              };

              print(feed.id);
              print(userInfoMap['id']);
              print("now adding comment.. for feedid ");
              print(feed.id);

              final url = Uri.parse('$backendUrl/api/comment'); // Replace with your API endpoint
              final body = jsonEncode({
                'postId': feed.id, // Assuming 'postId' is the field to link the comment to a post
                'content': text, // The text entered by the user
                'userId': int.parse(userInfoMap['id'])
              });

              final response = await http.post(
                url,
                headers: headers,
                body: body,
              );

              if (response.statusCode == 201) {
                // Comment successfully posted, you can handle the response accordingly
                print('Comment posted successfully');
                signUpAlert(
                  onPressed: () async {
                  print('back to the feeds page');
                  Navigator.popAndPushNamed(
                          context, EditProfileWidget.id);
                      Navigator.pushNamed(context, WelcomeScreen.id);
                  },
                  title: 'Comment Upload',
                  
                  desc:
                      'Comment posted successfully!',
                  btnText: 'Feed Now',
                  context: context,
              ).show();
              } else {
                // Handle the error if the request fails
                print('Failed to post comment');
              }
          }

        }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        height: 70.0,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo),
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: () {},
            ),
            Expanded(
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {
                      commentText = value;
                    }); // Update the comment text as the user types
                  },
                  decoration:
                      InputDecoration.collapsed(hintText: 'Add a cheerful comment'),
                )),
            IconButton(
              icon: Icon(Icons.send),
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                // Call the postComment method to send the comment text
                if (commentText.isNotEmpty) {
                  print(commentText);
                  postComment(commentText);
                  // Clear the text field after posting the comment
                  commentText = '';
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
                      border: Border.all(style: BorderStyle.solid, color: Colors.grey, width: 0.5)
                  ),
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
                              visible: widget.feed.title.isEmpty == true ? false : true,
                              child: Text(widget.feed.title,
                                  softWrap: true,
                                  maxLines: 2,
                                  style:
                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          space15(),
                          Visibility(
                              visible: widget.feed.content.isEmpty == true ? false : true,
                              child: Text(widget.feed.content,
                                  style: TextStyle(fontSize: 14, color: Colors.grey))),
                          space15(),
                          imageCarouselSlider(),
                          setLocation(context,widget.feed),
                          Divider(thickness: 1),
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.addressBook),
                              SizedBox(width: 10),
                              Text(
                                '${widget.feed.count.upvotes} Members supported the post',
                                style: TextStyle(
                                    fontSize: 14, color: Theme.of(context).primaryColor),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () =>print("comment section printed..")
                                          ,
                                        child: Row(
                                          children: <Widget>[
                                            Icon(FontAwesomeIcons.comment, size: 18),
                                            SizedBox(width: 5),
                                            Text('${widget.feed.count.comments}')
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


                Divider(thickness: 1),
                _buildMessageComposer(),
                Divider(thickness: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
