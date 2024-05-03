import 'dart:convert';

import 'package:ccw/screens/home.dart';
import 'package:ccw/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/constants.dart';
import 'package:ccw/screens/welcome.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ccw/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email;
  late String _password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.popAndPushNamed(context, HomeScreen.id);
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
                  Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/welcome.png'),
                      ),
                    ),
                  ),
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
                              fontSize: 18,
                            ),
                            decoration: kTextInputDecoration.copyWith(
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.mail, color: Colors.grey),
                            ),
                          ),
                        ),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                            decoration: kTextInputDecoration.copyWith(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            ),
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
                            print('$backendUrl/api/auth/signin');
                            try {
                              final response = await http.post(
                                Uri.parse('$backendUrl/api/auth/signin'),
                                body: {
                                  'email': _email,
                                  'password': _password,
                                },
                              );

                              if (response.statusCode == 201) {
                                print(response.body);
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString('userinfo', response.body);
                                final data = json.decode(response.body);
                                // check manager loggin and userloggin...

                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .setLoggedInStatus(data['userLogin'],
                                        data["orgManagerLogin"]);

                                setState(() {
                                  _saving = false;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (BuildContext context) =>
                                          HomePage(),
                                    ),
                                  );
                                });
                                // Navigator.pushNamed(context, WelcomeScreen.id);
                              }
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Incorrect Email or Password'),
                                    content: const Text(
                                        'Please check your email and password and try again.'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          // Add logic to delete the post
                                          setState(() {
                                            _saving = false;
                                          });
                                          Navigator.popAndPushNamed(
                                              context, LoginScreen.id);
                                        },
                                        child: const Text('Try Again'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              // signUpAlert(
                              //   context: context,
                              //   onPressed: () {
                              //     setState(() {
                              //       _saving = false;
                              //     });
                              //     Navigator.popAndPushNamed(
                              //         context, LoginScreen.id);
                              //   },
                              //   title: 'WRONG PASSWORD OR EMAIL',
                              //   desc:
                              //       'Confirm your email and password and try again',
                              //   btnText: 'Try Now',
                              // ).show();
                            }
                          },
                          questionPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Reset Your Password'),
                                  content: const Text(
                                      'Click the button below to reset your password.'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add logic to delete the post
                                        print(
                                            'This will be logged to the console in the browser.');
                                      },
                                      child: const Text('Reset Now'),
                                    ),
                                  ],
                                );
                              },
                            );
                            // signUpAlert(
                            //   onPressed: () async {
                            //     print(
                            //         'This will be logged to the console in the browser.');
                            //   },
                            //   title: 'RESET YOUR PASSWORD',
                            //   desc:
                            //       'Click on the button to reset your password',
                            //   btnText: 'Reset Now',
                            //   context: context,
                            // ).show();
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
