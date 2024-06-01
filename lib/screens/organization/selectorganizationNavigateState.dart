import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:ccw/screens/organization/listorganizationscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrganizationState extends StatefulWidget {
  const OrganizationState({super.key});

  @override
  State<OrganizationState> createState() => _OrganizationStateState();
}

class _OrganizationStateState extends State<OrganizationState>
    with TickerProviderStateMixin {
  int _selectedDrawerIndex = 0;

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  _selectedTab(int pos) {
    setState(() {
      _onSelectItem(pos);
    });

    switch (pos) {
      case 0:
        // return DashboardWidget();
        return const OrganizationListScreen(myOrganization: false);
      case 1:
        return const OrganizationListScreen(myOrganization: true);

      default:
        return const Text("Invalid screen requested");
    }
  }

  @override
  void initState() {
    super.initState();

    _selectedTab(_selectedDrawerIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedTab(_selectedDrawerIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: FloatingActionButton(
      //   tooltip: 'Create Post',
      //   splashColor: Colors.blue,
      //   onPressed: _modalBottomSheetMenu,
      //   child: Icon(CupertinoIcons.add),
      //   elevation: 0,
      // ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        backgroundColor: (Colors.white),
        color: Colors.blue,
        selectedColor: Theme.of(context).colorScheme.secondary,
        notchedShape: CircularNotchedRectangle(),
        iconSize: 20.0,
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: FontAwesomeIcons.listAlt, text: 'List'),
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons.book, text: 'MyOrganizations'),
          // FABBottomAppBarItem(
          //     iconData: FontAwesomeIcons.comments, text: 'Updates'),
          // FABBottomAppBarItem(
          //     iconData: FontAwesomeIcons.businessTime, text: 'Explore'),
        ],
      ),
    );
  }
}
