// Bloc Pattern for the feed.
// STEP-1: Imports
// STEP-2: List of Feeds
// STEP-3: Stream controller
// STEP-4: Stream sink getter
// STEP-5: Constructor - Add Likes, Listen to the changes
// STEP-6: Core functions
// STEP-7: Dispose
//Stream Is Already Been Cooked In Flutter

import 'dart:async';

class Status {
  final String name;
  

  Status({required this.name});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      name: json['name']
    );
  }
}



class Author {
  final Profile profile;

  Author({required this.profile});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      profile: Profile.fromJson(json['profile']),
    );
  }
}

class Profile {
  final String firstName;
  final String lastName;
  final String avatar; // Use String? for nullable fields

  Profile({
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    if(json['avatar']==null){
      json['avatar'] = 'https://www.w3schools.com/w3images/avatar1.png';
    }
    return Profile(
      firstName: json['firstName'],
      lastName: json['LastName'],
      avatar: json['avatar'],
    );
  }
}

class Count {
  final int upvotes;
  final int comments;

  Count({required this.upvotes, required this.comments});

  factory Count.fromJson(Map<String, dynamic> json) {
    return Count(
      upvotes: json['upvotes'],
      comments: json['comments'],
    );
  }
}



class GptFeed {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String city;
  final double latitude;
  final double longitude;
  final Author author;
  final Count count;
  final bool published;
  final String timestamp;
  final bool isupvote;
  final Status status;

  GptFeed({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.author,
    required this.count,
    required this.published,
    required this.timestamp,
    required this.isupvote,
    required this.status,
  });
  factory GptFeed.fromJson(Map<String, dynamic> json) {
    return GptFeed(
     id: json['id'],
    title: json['title'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    city: json['city'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    status: Status.fromJson(json['status']),
    published: json['published'],
    timestamp: json['timestamp'],
    isupvote: json['upvotes'].length>0? true:false,
    author: Author.fromJson(json['author']), // Parse Author
    count: Count.fromJson(json['_count']),      // Parse Count
    );
  }
}




class GptComment {
 
  final String content;
  
  final Author author;
  
  final String createdAt;

  GptComment({
    
    required this.content,
    
    required this.author,
    
    required this.createdAt,
  });
  factory GptComment.fromJson(Map<String, dynamic> json) {
    return GptComment(
    
    content: json['content'],
   
    createdAt: json['createdAt'],
    author: Author.fromJson(json['user']), // Parse Author
    );
  }
}





class Feed {

  int id, type, likes;
  String username, content,  timestamp, title, avatarImg, bannerImg, city, comments, members;

  Feed({required this.id,required  this.type,required  this.username,required  this.content,required, required this.timestamp,required  this.title,required  this.avatarImg,required  this.bannerImg,required  this.city,required  this.likes,required  this.comments,required  this.members});
}


class QuestionModel {

  String question;

  QuestionModel({required this.question});
}



class Category {
  bool isSelected = false;
  String categoryType;

  Category({required this.categoryType});
}

class FeedBloc {


  List<Feed> feedList = [


    Feed(
        id: 1,
        type: 0,
        username: 'rohit.shetty12',
        content:
        'I have been facing a few possible symptoms of skin cancer. I have googled the possibilities but i can thought i did asked the community instead...',
        timestamp: '1 min', // need to convert in min from backend
        title: 'What Are The Sign And Symptoms Of Skin Cancer?',//title 
        avatarImg: 'https://www.w3schools.com/w3images/avatar1.png',
        bannerImg: 'https://www.w3schools.com/w3images/avatar1.png', // no need
        city: 'Peninsula park Andheri, Mumbai', // city
        likes: 24,
        comments: '24',
        members: '24'
        ),

    Feed(
        id: 2,
        type: 0,
        username: 'rohit.shetty02',
        content:
        'My husband has his 3 days transpalnt assessment in Newcastle next month, strange mix of emotions. for those that have been thought this how long did it take following assessment was it intil you were t...',
        timestamp: '10 min',
        title: '',
        avatarImg: 'https://www.w3schools.com/w3images/avatar1.png',
        bannerImg: 'https://www.w3schools.com/w3images/avatar1.png',
        city: 'Peninsula park Andheri, Mumbai',
        likes: 23,
        comments: '2',
        members: '12'),

    Feed(
        id: 3,
        type: 0,
        username: 'username1275',
        content: '',   
        timestamp: '10 min',
        title: 'Cancer Meet At Rajiv Gandhi National Park',
        avatarImg: 'https://www.w3schools.com/w3images/avatar1.png',
        bannerImg: 'https://www.w3schools.com/w3images/avatar1.png',
        city: 'Peninsula park Andheri, Mumbai',
        likes: 23,
        comments: '2',
        members: '12'),

    Feed(
        id: 4,
        type: 0,
        username: 'super987',
        content: '#itsokeyto #cancerserviver',  
        timestamp: '10 min',
        title: 'Something To Motivate You',
        avatarImg: 'https://www.w3schools.com/w3images/avatar4.png',
        bannerImg: 'https://www.w3schools.com/w3images/avatar4.png',
        city: 'Peninsula park Andheri, Mumbai',
        likes: 25,
        comments: '24',
        members: '18'),

    Feed(
        id: 5,
        type: 0,
        username: 'username1275',
        content: '#itsokeyto #cancerserviver',
        timestamp: '1 min',
        title: 'What is the best hospital in india for the cancer?',
        avatarImg: 'https://www.w3schools.com/w3images/avatar4.png',
        bannerImg: 'https://www.w3schools.com/w3images/avatar4.png',
        city: 'Peninsula park Andheri, Mumbai',
        likes: 25,
        comments: '24',
        members: '18'),
  ];


  // 2. Stream controller
  final _feedListStreamController = StreamController<List<Feed>>();
  final _feedLikeIncrementController = StreamController<Feed>();
  final _feedLikeDecrementController = StreamController<Feed>();

  // 3. Stream Sink Getter
  Stream<List<Feed>> get feedListStream => _feedListStreamController.stream;
  StreamSink<List<Feed>> get feedListSink => _feedListStreamController.sink;

  StreamSink<Feed> get feedLikeIncrement => _feedLikeIncrementController.sink;
  StreamSink<Feed> get feedLikeDecrement => _feedLikeDecrementController.sink;

  // Constructor




  FeedBloc()
  {
    _feedListStreamController.add(feedList);
    _feedLikeIncrementController.stream.listen(_incrementLike);
    _feedLikeDecrementController.stream.listen(_decrementLike);
  }

  _incrementLike(Feed feed)
  {
    int like = feed.likes;
    int incrementLike = like + 1;
    feedList[feed.id - 1].likes = like + incrementLike;
    feedListSink.add(feedList);
  }

  _decrementLike(Feed feed)
  {
    int like = feed.likes;
    int decrementLike = like - 1;
    feedList[feed.id - 1].likes = like - decrementLike;
    feedListSink.add(feedList);
  }

  dispose()
  {
    _feedLikeDecrementController.close();
    _feedLikeIncrementController.close();
    _feedListStreamController.close();
  }
}
