import 'dart:convert';
import 'package:ccw/screens/otp_screen.dart';
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

class OtpResponse {
  final String email;
  final String token;

  OtpResponse({required this.email, required this.token});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    // Extract users list from the JSON if it exists

    return OtpResponse(
        email: json['email'] as String, token: json['token'] as String);
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String _email;
  late String _password;
  late String _confirmPass;
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
                const ScreenTitle(title: 'Sign Up'),
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
                    obscureText: false,
                    onChanged: (value) {
                      _password = value;
                    },
                    style: const TextStyle(fontSize: 18),
                    decoration: kTextInputDecoration.copyWith(
                      hintText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
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
                      textButton: 'Sign Up',
                      heroTag: 'signup_btn',
                      question: '',
                      buttonPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _saving = true;
                        });
                        // if (_confirmPass == _password) {
                        try {
                          log('$backendUrl/api/user/signup');
                          print(_password);
                          final response = await http.post(
                            Uri.parse('$backendUrl/api/user/signup'),
                            body: {
                              'email': _email,
                              'FullName': _password,
                            },
                          );

                          if (response.statusCode == 201) {
                            final data = json.decode(response.body);
                            OtpResponse otpres = OtpResponse.fromJson(data);

                            print(otpres);
                            print(otpres.token);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text(
                                      'Password creation instructions sent to your email.'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the success dialog.
                                        Navigator.push<void>(
                                          context,
                                          MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                OtpScreen(
                                              token: otpres.token,
                                            ),
                                          ),
                                        ); // Navigate to OTP screen.
                                      },
                                      child: const Text('OK'),
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
