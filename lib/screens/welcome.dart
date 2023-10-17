import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccw/components/components.dart';



class MenuModel {
  String title;
  String subtitle;
  IconData icon;

  MenuModel(this.title, this.subtitle, this.icon);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  static String id = 'welcome_screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>  with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    int _selectedDrawerIndex = 0;
     List<MenuModel> bottomMenuItems =  <MenuModel>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: const Center(
          child: ScreenTitle(
            title: 'Welcome',
          ),
        ),
      ),
    );
  }
}
