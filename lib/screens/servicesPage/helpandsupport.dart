import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:flutter/material.dart';

class HelpAndSupport extends StatefulWidget {
  static String id = 'help_screen';
  @override
  _HelpAndSupportState createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  List<Item> _data = generateItems(3);

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
      body: ListView(
        children: _data.map<Widget>((Item item) {
          return Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              child: ExpansionTile(
                iconColor: Colors.teal, // Icon color for the expansion tile
                title: Text(item.question),
                children: [
                  ListTile(
                    title: Text(
                      item.answer,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class Item {
  Item({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
  bool isExpanded = false;
}

List<Item> generateItems(int numberOfItems) {
  return [
    Item(
      question: 'How do I report an illegal garbage dumping incident?',
      answer:
          'To report an incident, open the Clean City Watch app, navigate to the "Report" section, and provide details about the location and situation. You can also attach photos as evidence.',
    ),
    Item(
      question: 'Is the app available for both Android and iOS devices?',
      answer:
          'Yes, the Clean City Watch app is available for both Android and iOS devices. You can download it from the respective app stores.',
    ),
    Item(
      question: 'Can I track the status of my reported incidents?',
      answer:
          "Yes, you can track the status of your reported incidents by going to the 'My Reports' section in the app. You'll receive updates as authorities address the issues.",
    ),
    // Add more FAQ items here...
  ];
}
