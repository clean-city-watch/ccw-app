import 'package:ccw/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const TopScreenImage(screenImageName: 'ccw-logo.png'),
              const SizedBox(height: 20),
              const ScreenTitle(title: 'Hello'),
              const SizedBox(height: 10),
              const Text(
                'Welcome to CleanCityWatch, where you manage your city',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'login_btn',
                child: CustomButton(
                  buttonText: 'Login',
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final userInfo = prefs.getString('userinfo');

                    print("printing user info");
                    print(userInfo);

                    if (userInfo != null) {
                      Map<String, dynamic> userInfoMap = json.decode(userInfo);
                      String accessToken = userInfoMap['access_token'];
                      print(accessToken);
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => HomePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Hero(
                tag: 'signup_btn',
                child: CustomButton(
                  buttonText: 'Sign Up',
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushNamed(context, SignUpScreen.id);
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Sign up using',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 25,
                      child: Image.asset('assets/images/icons/facebook.png'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: Image.asset('assets/images/icons/google.png'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      radius: 25,
                      child: Image.asset('assets/images/icons/linkedin.png'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
