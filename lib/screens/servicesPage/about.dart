import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: actionBarRow(context),
        centerTitle: false,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ccw-logo.png', // Replace with your logo image path
              width: 250,
              height: 250,
            ),
            // SizedBox(height: 16.0),
            Text(
              'The Clean City Watch project is an innovative solution to address the critical issue '
              'of illegal garbage dumping in urban areas. Our user-friendly mobile application empowers '
              'citizens to report and resolve instances of garbage dumping, leading to improved '
              'environmental impact, public health, and the overall quality of life in cities.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'With the increasing challenges posed by improper waste disposal, the Clean City Watch '
              'app provides an efficient reporting mechanism that allows users to capture and submit '
              'information about illegal dumping incidents. This data is then used to optimize cleanup '
              'efforts and foster collaboration between communities and local authorities.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Our mission is to create cleaner, more sustainable cities by engaging citizens in the '
              'effort to combat garbage dumping. By utilizing modern technology, effective communication, '
              'and data accessibility, we aim to bridge the gap between residents and authorities, '
              'ultimately contributing to the improvement of urban environments.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}