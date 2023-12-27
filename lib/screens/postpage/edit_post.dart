import 'dart:io';

import 'package:ccw/components/components.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:ccw/screens/newsFeedPage/widgets/feedBloc.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';



class EditPostWidget extends StatefulWidget {
  final GptFeed feed;

  EditPostWidget({required this.feed});

  @override
  _EditPostWidgetState createState() => _EditPostWidgetState();
}

class _EditPostWidgetState extends State<EditPostWidget> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  late TextEditingController cityController;
  String selectedCity = '';
  String imageUrl = '';
  File? _pickedFile;
  bool _saving = false;


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.feed.title);
    contentController = TextEditingController(text: widget.feed.content);
    latitudeController = TextEditingController(text: widget.feed.latitude.toString());
    longitudeController = TextEditingController(text: widget.feed.longitude.toString());
    cityController = TextEditingController(text: widget.feed.city);
    _getImage(widget.feed.imageUrl);
   
  }


  Future<void> _uploadFile() async {
    if (_pickedFile == null) {
      return;
    }

    
    final postId = widget.feed.id;
    final url = Uri.parse('$backendUrl/api/post/$postId/upload');
    print(url);
    // Replace 'file' with the field name expected by your API for the file upload
    var request = http.MultipartRequest('PUT', url)
      ..files.add(await http.MultipartFile.fromPath('file', _pickedFile!.path));

    try {
      setState(() {
        _saving = true;
      });
      final response = await request.send();
      print(response);

      if (response.statusCode == 201) {
        // File uploaded successfully, handle accordingly
                
        signUpAlert(
            context: context,
            onPressed: () {
              setState(() {
                _saving = false;
              });
              
              
              Navigator.pop(context);
            },
            title: 'File Upload',
            desc:
                'File Uploaded Successfully!',
            btnText: 'continue',
          ).show();
        print('File uploaded successfully');
      } else {
        // Handle the error case
        print('Failed to upload file');
      }
    } catch (error) {
      // Handle network errors or exceptions
      print('Error: $error');
    }
  }



  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }


  Future<void> _getImage(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

   if(userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
        
      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };

        
        final response = await http.get(Uri.parse('$backendUrl/api/minio/covers/$fileName'),headers: headers);
      
      if (response.statusCode == 200) {
        
      final Map<String, dynamic> responseData = json.decode(response.body);
      
       setState(() {
                imageUrl = responseData['imageUrl'];
        });
      
      }
   
   }
   



  }

  Future<void> _editPost(Post post) async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('userinfo');

   if(userInfo != null) {
      Map<String, dynamic> userInfoMap = json.decode(userInfo);
      String accessToken = userInfoMap['access_token'];
        
      var headers = {
        "Authorization": "Bearer ${accessToken}",
      };

        print('I am here..');
     final response = await http.put(Uri.parse('$backendUrl/api/post'),headers: headers,body: post.toJson());
      
      if (response.statusCode == 202) {
      
        print('Post updated successfully');
        Navigator.pop(context); // Close the edit post screen
      
      }
   
   }
   



  }

  @override
  Widget build(BuildContext context) {
    final GptFeed feed = widget.feed;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: latitudeController,
                decoration: InputDecoration(labelText: 'Latitude'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: longitudeController,
                decoration: InputDecoration(labelText: 'Longitude'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              SizedBox(height: 20.0),
              _pickedFile != null
                ? Image.file(
                    _pickedFile!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text('Pick a File'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadFile,
                child: Text('Upload File'),
              ),
              
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
              ElevatedButton(
                onPressed: () {
                  final editedPost = Post(
                    id: feed.id.toString(),
                    title: titleController.text,
                    content: contentController.text,
                    city: cityController.text,
                    latitude: latitudeController.text,
                    longitude: longitudeController.text,
                  );

                  print(editedPost.toJson());
                  _editPost(editedPost);
                },
                child: Text('Save Post'),
              ),
            ],
          ),
        ),
      ),
    );

  }
}

class Post {
  String id;
  String title;
  String content;
  String city;
  String latitude;
  String longitude;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.city,
    required this.latitude,
    required this.longitude,

  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'city': city,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
