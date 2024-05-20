import 'dart:convert';

import 'package:ccw/consts/env.dart';
import 'package:ccw/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccw/components/components.dart';
import 'package:ccw/constants.dart';
import 'package:ccw/screens/home.dart';
import 'package:loading_overlay/loading_overlay.dart';

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
                      image: AssetImage('assets/images/welcome.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const ScreenTitle(title: 'Login'),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
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
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CustomBottomScreen(
                      textButton: 'Login',
                      heroTag: 'login_btn',
                      question: '',
                      buttonPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        setState(() {
                          _saving = true;
                        });
                        try {
                          final response = await http.post(
                            Uri.parse('$backendUrl/api/auth/signin'),
                            body: {
                              'email': _email,
                              'password': _password,
                            },
                          );

                          if (response.statusCode == 201) {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('userinfo', response.body);
                            final data = json.decode(response.body);
                            Provider.of<UserProvider>(context, listen: false)
                                .setLoggedInStatus(
                                    data['userLogin'], data["orgManagerLogin"]);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => HomePage(),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _saving = false;
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Login Failed'),
                                content: const Text(
                                    'Incorrect Email or Password. Please try again.'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      questionPressed: () => {print("pressed")},
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
