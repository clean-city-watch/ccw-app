import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  static String id = 'example_screen';
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String content = 'Initial Content';

  void navigateToSecondPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage(content: content)),
    );

    if (result != null) {
      setState(() {
        content = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Content on First Page:',
            ),
            Text(
              content,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToSecondPage,
              child: Text('Edit Content'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final String content;

  SecondPage({required this.content});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter Content'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}