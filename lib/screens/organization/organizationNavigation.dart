import 'package:ccw/screens/organization/organizationUserWidget.dart';
import 'package:ccw/screens/organization/organizationdetailScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrganizationNavigation extends StatefulWidget {
  final int organizationId;

  const OrganizationNavigation({required this.organizationId});

  @override
  State<OrganizationNavigation> createState() => _OrganizationNavigationState();
}

class _OrganizationNavigationState extends State<OrganizationNavigation> {
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
        return OrganizationDetailScreen(organizationId: widget.organizationId);
      case 1:
        return OrganizationUsers(organizationId: widget.organizationId);

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
      //   splashColor: Colors.teal,
      //   onPressed: _modalBottomSheetMenu,
      //   child: Icon(CupertinoIcons.add),
      //   elevation: 0,
      // ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        backgroundColor: (Colors.black54),
        color: (Color.fromARGB(255, 177, 177, 177))!,
        selectedColor: Theme.of(context).colorScheme.secondary,
        notchedShape: CircularNotchedRectangle(),
        iconSize: 20.0,
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: FontAwesomeIcons.listAlt, text: 'Details'),
          FABBottomAppBarItem(
              iconData: FontAwesomeIcons.book, text: 'Users'),
          // FABBottomAppBarItem(
          //     iconData: FontAwesomeIcons.comments, text: 'Updates'),
          // FABBottomAppBarItem(
          //     iconData: FontAwesomeIcons.businessTime, text: 'Explore'),
        ],
      ),
    );
  }
}