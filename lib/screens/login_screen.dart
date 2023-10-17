import 'package:flutter/material.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/constants.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ccw/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';
  

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ScreenTitle(title: 'Login'),
                        CustomTextField(
                          textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email')),
                        ),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password'),
                          ),
                        ),
                        CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question: 'Forgot password?',
                          buttonPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _saving = true;
                            });
                            try {
                                final response = await http.post(
                                      Uri.parse('$backendUrl/api/user/signin'),
                                      body: {
                                        'email': _email,
                                        'password': _password,
                                      },
                                    );

                              if (response.statusCode == 201) {
                                print(response.body);
                                 final prefs = await SharedPreferences.getInstance();
                                prefs.setString('userinfo', response.body);
                                setState(() {
                                  _saving = false;
                                  Navigator.popAndPushNamed(
                                      context, LoginScreen.id);
                                });
                                Navigator.pushNamed(context, WelcomeScreen.id);
                              }
                            } catch (e) {
                              signUpAlert(
                                context: context,
                                onPressed: () {
                                  setState(() {
                                    _saving = false;
                                  });
                                  Navigator.popAndPushNamed(
                                      context, LoginScreen.id);
                                },
                                title: 'WRONG PASSWORD OR EMAIL',
                                desc:
                                    'Confirm your email and password and try again',
                                btnText: 'Try Now',
                              ).show();
                            }
                          },
                          questionPressed: () {
                            signUpAlert(
                              onPressed: () async {
                               print('This will be logged to the console in the browser.');
                              },
                              title: 'RESET YOUR PASSWORD',
                              desc:
                                  'Click on the button to reset your password',
                              btnText: 'Reset Now',
                              context: context,
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
