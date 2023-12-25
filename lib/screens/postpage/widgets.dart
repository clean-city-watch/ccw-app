import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:ccw/screens/newsFeedPage/widgets/feedCard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

Widget linearProgressIndicator() {
  return LinearProgressIndicator(
    backgroundColor: Colors.red,
  );
}

Widget othersComment(BuildContext context, GptComment comment) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
            backgroundColor: Colors.grey,
            child: ClipOval(
                child: Image.network(
                    comment.author.profile.avatar)),
            radius: 20),
        SizedBox(width: 20),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  style: BorderStyle.solid, color: Colors.grey, width: 0.5)),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  usernameSectionWithoutAvatar(context,comment),
                  space15(),
                  Text(
                      comment.content,
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(fontSize: 14)),
                  // space15(),
                  // Divider(thickness: 1),
                  // SizedBox(height: 10),
                  // // menuReply(feed),
                  // space15(),
                ],
              ),
            ),
          ),
        )
            //commentReply(context, FeedBloc().feedList[2]),
            )
      ],
    ),
  );
}

Widget othersCommentWithImageSlider(BuildContext context, GptComment feed) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
            backgroundColor: Colors.grey,
            child: ClipOval(
                child: Image.network(
                    'https://www.w3schools.com/w3images/avatar4.png')),
            radius: 20),
        SizedBox(width: 20),
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  style: BorderStyle.solid, color: Colors.grey, width: 0.5)),
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  usernameSectionWithoutAvatar(context,feed),
                  space15(),
                  Text(
                      'Not sure about rights. Looks like its matter of concern that our shool dont take it seriously such matters and trats it like lightly that it is fault of student',
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(fontSize: 14)),
                  space15(),
                  imageCarouselSlider(),
                  Divider(thickness: 1),
                  SizedBox(height: 10),
                  // menuReply(feed),
                  space15(),
                ],
              ),
            ),
          ),
        )
            //commentReply(context, FeedBloc().feedList[2]),
            )
      ],
    ),
  );
}

Widget imageCarouselSlider() {
  var imageSlider = [
    'http://192.168.1.34:9000/test/1703495479229-doit.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=b0jA4AKyGCWtrr2plYo6%2F20231225%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231225T091255Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=bcfd112b2e4722504b784cdd4785737e6d7f6390cbe7d236a560dc038d7ea034',
    'https://images.pexels.com/photos/618612/pexels-photo-618612.jpeg',
    'https://2rdnmg1qbg403gumla1v9i2h-wpengine.netdna-ssl.com/wp-content/uploads/sites/3/2019/05/kidsRaceAge-891544116-770x553-650x428.jpg',
    'https://media.gettyimages.com/photos/working-out-by-the-ocean-picture-id621494554?s=612x612'
  ];
  return CarouselSlider(
    options: CarouselOptions(
      height: 150.0,
      enableInfiniteScroll: true,
      autoPlay: true,
      scrollDirection: Axis.horizontal,
      autoPlayAnimationDuration: Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
    ),
    items: imageSlider.map((i) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: Colors.grey[300]),
              child: Image.network(
                i,
                fit: BoxFit.cover,
              ));
        },
      );
    }).toList(),
  );
}

Widget menuReply(GptFeed listFeed) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onTap: () => debugPrint('${listFeed.count.upvotes} tapped'),
              child: Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.arrowUp,
                    size: 16,
                    color: Colors.teal,
                  ),
                  SizedBox(width: 5),
                  Text(
                    '${listFeed.count.upvotes}',
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () => debugPrint('Comment Tapped'),
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.arrowDown, size: 16),
                        SizedBox(width: 5),
                        Text(
                          '${listFeed.count.comments}',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
              ]),
          GestureDetector(
              onTap: () {
               print('share code');
              },
              child: Icon(Icons.share, size: 18)),
          Text('Reply',
              style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))
        ],
      ),
      SizedBox(height: 20),
      Container(
        padding: EdgeInsets.only(left: 20),
        child: Text('2 Replies',
            style: TextStyle(color: Colors.teal, fontSize: 14)),
      )
    ],
  );
}

Widget usernameSectionWithoutAvatar(BuildContext context,GptComment comment) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(comment.author.profile.firstName +" "+comment.author.profile.lastName ,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 10,
                        ),
                        Text('1Min',
                            style: TextStyle(fontSize: 14, color: Colors.grey))
                      ],
                    ),
                    SizedBox(height: 4),
                    Text('user description',
                        style: TextStyle(fontSize: 12, color: Colors.teal)),
                  ],
                )
              ],
            ),
            // moreOptions3Dots(context,comment),
          ],
        ),
      )
    ],
  );
}

Widget commentReply(BuildContext context, GptComment comment) {
  return Container(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
            child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                  style: BorderStyle.solid, color: Colors.grey, width: 0.5)),
          child: Container(
            color: Colors.grey[300],
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  //usernameSectionWithoutAvatar(context),
                  //space15(),
                  Text(
                      comment.content,
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(fontSize: 14)),
                  
                ],
              ),
            ),
          ),
        )
            //commentReply(context, FeedBloc().feedList[2]),
            ),
        SizedBox(width: 20),
        CircleAvatar(
            backgroundColor: Colors.grey,
            child: ClipOval(
                child: Image.network(
                    'https://www.w3schools.com/w3images/avatar4.png')),
            radius: 20),
      ],
    ),
  );
}

Widget menuCommentReply(GptFeed listFeed) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      GestureDetector(
          onTap: () => debugPrint('${listFeed.count.upvotes} tapped'),
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.arrowUp,
                size: 16,
                color: Colors.teal,
              ),
              SizedBox(width: 5),
              Text(
                '${listFeed.count.upvotes}',
                style: TextStyle(
                    color: Colors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              )
            ],
          )),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () => debugPrint('Comment Tapped'),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.arrowDown, size: 16),
                    SizedBox(width: 5),
                    Text(
                       '${listFeed.count.upvotes}',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                ))
          ]),
      GestureDetector(
          onTap: () {
           print('share code');
          },
          child: Icon(Icons.share, size: 18)),
      GestureDetector(onTap: () {}, child: Icon(Icons.linear_scale, size: 18)),
    ],
  );
}
