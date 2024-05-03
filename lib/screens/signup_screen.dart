import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/screens/home_screen.dart';
import 'package:ccw/screens/login_screen.dart';
import 'package:ccw/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:http/http.dart' as http;
import 'package:ccw/consts/env.dart' show backendUrl;
import 'dart:developer';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  late String _confirmPass;
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'signup.png'),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'Sign Up'),
                          CustomTextField(
                            textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Email',
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
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password',
                              ),
                            ),
                          ),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _confirmPass = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Confirm Password',
                              ),
                            ),
                          ),
                          CustomBottomScreen(
                            textButton: 'Sign Up',
                            heroTag: 'signup_btn',
                            question: 'Have an account?',
                            buttonPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _saving = true;
                              });
                              if (_confirmPass == _password) {
                                try {
                                  log('$backendUrl/api/user/signup');
                                  final response = await http.post(
                                    Uri.parse('$backendUrl/api/user/signup'),
                                    body: {
                                      'email': _email,
                                      'password': _password,
                                    },
                                  );

                                  if (response.statusCode == 201) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Good Job!'),
                                          content: const Text(
                                              "You've done a great job! Proceed to login."),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              onPressed: () {
                                                // Add logic to delete the post
                                                setState(() {
                                                  _saving = false;
                                                });
                                                Navigator.pushNamed(
                                                    context, LoginScreen.id);
                                              },
                                              child: const Text('Login Now'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Something Went Wrong'),
                                        content: const Text(
                                            "Please close the app and try again."),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            onPressed: () {
                                              // Add logic to delete the post
                                              SystemNavigator.pop();
                                            },
                                            child: const Text('Close Now'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text('Passwords Do Not Match'),
                                      content: const Text(
                                          "Please make sure that you enter the same password twice."),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            // Add logic to delete the post
                                            // Navigator.pop(context);
                                            Navigator.popAndPushNamed(
                                                context, SignUpScreen.id);
                                          },
                                          child: const Text('Cancle'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            questionPressed: () async {
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                          ),
                        ],
                      ),
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
