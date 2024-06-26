import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:ccw/screens/web_view_Swach_bharat.dart';
import 'package:ccw/screens/web_view_trash_ai.dart';
import 'package:ccw/screens/libraryPage/library.dart';
import 'package:ccw/screens/messagePage/messages.dart';
import 'package:ccw/screens/newsFeedPage/NewsFeed.dart';
import 'package:ccw/screens/servicesPage/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ccw/screens/custom/fab_bottom_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ccw/screens/create_post.dart';
import 'package:ccw/screens/profile/edit_profile.dart';
import 'package:ccw/screens/dashboard/dashboardscreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedDrawerIndex = 0;
  List<MenuModel> bottomMenuItems = <MenuModel>[];

  _selectedTab(int pos) {
    setState(() {
      _onSelectItem(pos);
    });

    switch (pos) {
      case 0:
        // return DashboardWidget();
        return NewsFeed();
      case 1:
        return LibraryPage();
      case 2:
        return MessagesPage();
      case 3:
        return ServicePage();
      default:
        return Text("Invalid screen requested");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
  }

  @override
  void initState() {
    super.initState();

    _selectedTab(_selectedDrawerIndex);
    bottomMenuItems.add(new MenuModel('Create a post',
        'Share your thoughts with the community', Icons.colorize));
    bottomMenuItems.add(new MenuModel('Register an issue',
        'Register issue with the community', Icons.colorize));
    bottomMenuItems.add(new MenuModel(
        'Trash AI', 'Explore AI solution for Trash.', Icons.info));
    bottomMenuItems.add(
        new MenuModel('Swatch Bharat', 'Major Initiatives', Icons.equalizer));
    // bottomMenuItems.add(new MenuModel('Organise an Event',
    //     'Start a meet with people to share your joys', Icons.event));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
          color: Colors.grey.shade700,
          selectedColor: Colors.teal,
          notchedShape: CircularNotchedRectangle(),
          iconSize: 20.0,
          onTabSelected: _selectedTab,
          items: [
            FABBottomAppBarItem(
                iconData: FontAwesomeIcons.listAlt, text: 'Home'),
            FABBottomAppBarItem(
                iconData: FontAwesomeIcons.book, text: 'Activity'),
            FABBottomAppBarItem(
                iconData: FontAwesomeIcons.comments, text: 'Updates'),
            FABBottomAppBarItem(
                iconData: FontAwesomeIcons.businessTime, text: 'Explore'),
          ],
        ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        CreatePost(
                                      type: "POST",
                                    ),
                                  ),
                                );
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        CreatePost(
                                      type: "ISSUE",
                                    ),
                                  ),
                                );
                              case 2:
                                Navigator.pushNamed(context, WebViewTrashAI.id);
                              case 3:
                                Navigator.pushNamed(
                                    context, WebViewSwatchBharat.id);
                              case 4:
                                debugPrint(bottomMenuItems[index].title);
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
