import 'package:ccw/screens/leadboard/leadboardscreen.dart';
import 'package:ccw/screens/newsFeedPage/widgets/widgetFeed.dart';
import 'package:ccw/screens/organization/listorganizationscreen.dart';
import 'package:ccw/screens/organization/selectorganizationNavigateState.dart';
import 'package:flutter/material.dart';


class CategoryList extends StatefulWidget {

  CategoryList({Key? key}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {

  List<String> listCategory = [
    'All posts',
    'Leadboard',
    'Organizations'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemCount: listCategory.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                debugPrint('${listCategory[index]} Tapped');
                if(listCategory[index]=='Leadboard'){
                   Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LeaderboardScreen()));
                }else if (listCategory[index]=='Organizations'){
                   Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OrganizationState())); 
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                decoration: index == 0 ? selectedBoxDecoration() : boxDecoration(),
                child: Text(
                  listCategory[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.teal, fontSize: 14),
                ),
              ),
            );
          }),
    );
  }


}
