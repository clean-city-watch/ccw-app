import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:ccw/screens/organization/createOrganization.dart';
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
  List<MenuModel> bottomMenuItems = <MenuModel>[
    new MenuModel('Create Organization', 'Onboard organization into community',
        Icons.colorize)
  ];

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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Post',
        splashColor: Colors.teal,
        onPressed: _modalBottomSheetMenu,
        child: Icon(CupertinoIcons.add),
        elevation: 0,
        shape: CircleBorder(),
      ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: '',
        backgroundColor: (Colors.white),
        color: Color(0xFF737373),
        selectedColor: Colors.teal,
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

  _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 440.0,
            color: Color(0xFF737373),
            child: Column(
              children: <Widget>[
                Container(
                  height: 300.0,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: new BoxDecoration(
                      color: Colors.white, //Color(0xFF737373),
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: ListView.builder(
                      itemCount: bottomMenuItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.teal[100],
                            ),
                            child: Icon(
                              bottomMenuItems[index].icon,
                              color: Colors.teal,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          title: Text(
                            bottomMenuItems[index].title,
                            style: TextStyle(color: Colors.teal, fontSize: 18),
                          ),
                          subtitle: Text(bottomMenuItems[index].subtitle),
                          onTap: () {
                            Navigator.pop(context);
                            debugPrint(bottomMenuItems[index].title);
                            debugPrint('$index');
                            switch (index) {
                              case 0:
                                Navigator.pushNamed(
                                    context, CreateOrganization.id);
                              default:
                                debugPrint(bottomMenuItems[index].title);
                            }
                          },
                        );
                      }),
                ),

                //SizedBox(height: 10),

                Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            size: 25, color: Colors.grey[900]))),
              ],
            ),
          );
        });
  }
}

class MenuModel {
  String title;
  String subtitle;
  IconData icon;

  MenuModel(this.title, this.subtitle, this.icon);
}
