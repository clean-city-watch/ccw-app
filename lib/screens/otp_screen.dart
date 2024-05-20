import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccw/consts/env.dart' show backendUrl;
import 'package:ccw/components/components.dart';
import 'package:ccw/constants.dart';
import 'package:ccw/screens/home_screen.dart';
import 'package:ccw/screens/login_screen.dart';
import 'dart:developer';

class OtpScreen extends StatefulWidget {
  final String token;

  static String id = 'otp_screen';

  OtpScreen({required this.token});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String _email;
  late String _password;
  late String _confirmPass;
  late String _otp;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _saving,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/signup.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const ScreenTitle(title: 'Update Password'),
                const SizedBox(height: 20),
                CustomTextField(
                  textField: TextField(
                    onChanged: (value) {
                      _email = value;
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: kTextInputDecoration.copyWith(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textField: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      _password = value;
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: kTextInputDecoration.copyWith(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  textField: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      _confirmPass = value;
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: kTextInputDecoration.copyWith(
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextField(
                  textField: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      _otp = value;
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: kTextInputDecoration.copyWith(
                      hintText: 'OTP',
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                      child: const Text(
                        'Have an account?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomBottomScreen(
                      textButton: 'Update',
                      heroTag: 'signup_btn',
                      question: '',
                      buttonPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _saving = true;
                        });
                        if (_confirmPass == _password) {
                          try {
                            log('$backendUrl/api/update-password/email/$_email/token/${widget.token}');
                            final response = await http.put(
                              Uri.parse(
                                  '$backendUrl/api/update-password/email/$_email/token/${widget.token}'),
                              body: {
                                'email': _email,
                                'password': _password,
                                'token': widget.token,
                                'otp': _otp
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
                                  title: const Text('Something Went Wrong'),
                                  content: const Text(
                                      "Please close the app and try again."),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
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
                                title: const Text('Passwords Do Not Match'),
                                content: const Text(
                                    "Please make sure that you enter the same password twice."),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.popAndPushNamed(
                                          context, OtpScreen.id);
                                    },
                                    child: const Text('Cancel'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
