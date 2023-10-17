import 'package:flutter/material.dart';
import 'package:ccw/screens/home_screen.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/signup_screen.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:ccw/screens/home.dart';
import 'package:ccw/screens/create_post.dart';
import 'package:ccw/screens/profile/edit_profile.dart';
import 'package:ccw/screens/servicesPage/helpandsupport.dart';



// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.grey,  
          fontFamily: 'nunito',
          
          textTheme: const TextTheme(
            
          bodyMedium: TextStyle(
            fontFamily: 'Ubuntu',
          ),
      )),
      initialRoute: HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        SignUpScreen.id: (context) => SignUpScreen(),
        WelcomeScreen.id: (context) => HomePage(),
        CreatePost.id: (context) => CreatePost(),
        EditProfileWidget.id: (context) => EditProfileWidget(),
        HelpAndSupport.id: (context) => HelpAndSupport(),
      },
    );
  }
}