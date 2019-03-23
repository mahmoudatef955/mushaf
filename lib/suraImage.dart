import 'package:flutter/material.dart';
import 'getImage.dart';
import 'sqliteLoad.dart';
import 'dart:convert';
import 'sqliteLoad.dart';
import 'SuraResult.dart';


class suraImage extends StatefulWidget {
  suraImageState createState() => suraImageState();
}

class suraImageState extends State<suraImage> {
  bool _showbar = true;

  void _togglebar() {
    setState(() {
      _showbar = !_showbar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: <Widget>[
          GestureDetector(
            child: getImage(),
            onTap: _togglebar,
          ),
          Opacity(
            child: customAppbar(),
            opacity: _showbar ? 1.0 : 0.0,
            //duration: Duration(milliseconds: 500),
  
          ),

          /*
          _showbar
              ? customAppbar()
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
                */
          _showbar
              ? customButtomBar()
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
class customAppbar extends StatefulWidget {
  customAppbarState createState() => customAppbarState();
  //DBHelper db =DBHelper();
}

class customAppbarState extends State<customAppbar> {

void _showDialog(){
  DBHelper dbHelper =DBHelper();
  //var ayaList = widget.db.getSuraTable();
  //print(jsonEncode(ayaList));
  showDialog(
    context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         content:FutureBuilder<List<SuraResult>>(
        future: dbHelper.getSuraTable(),
        builder: (BuildContext context, AsyncSnapshot<List<SuraResult>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                SuraResult item = snapshot.data[index];
                return ListTile(
                  title: Text(item.name),
                  leading: Text(item.id.toString()),
                  
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
       );
     }
  );
}

  Widget _drawer(BuildContext context) {
    return Container(
      width: 40.0,
      height: 50.0,
      child: IconButton(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        icon: Icon(
          Icons.menu,
          color: Colors.green,
          size: 45.0,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  Widget fawasel() {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.bookmark),
        ),
        Text("الفواصل"),
      ],
    );
  }

  Widget faslgded() {
    return Column(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.bookmark),
        ),
        Text("فاصل جديد"),
      ],
    );
  }

  Widget ayaSelection() {
    return Container(
      width: 170.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          IconButton(
            onPressed: _showDialog,
            icon: Icon(Icons.arrow_drop_down),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text("الفاتحة"),
                Text("الاية 1"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return new Container(
      height: 110.0,
      width: 2.3,
      color: Colors.grey,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      height: 120.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          faslgded(),
          divider(),
          fawasel(),
          divider(),
          ayaSelection(),
          _drawer(context),
        ],
      ),
    );
  }
}

class customButtomBar extends StatefulWidget {
  customButtomBarState createState() => customButtomBarState();
}

class customButtomBarState extends State<customButtomBar> {
  Widget firstRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 35.0,
            margin: EdgeInsets.fromLTRB(10.0, 0.0, 5.0, 0.0),
            padding: EdgeInsets.fromLTRB(13.0, 0.0, 0.0, 0.0),
            child: Row(
              children: <Widget>[
                Text(
                  "الحذيفى",
                ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            decoration: new BoxDecoration(
              color: Colors.green,

              borderRadius: new BorderRadius.circular(15.0),
              //color: Colors.black
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RawMaterialButton(
              shape: const CircleBorder(),
              fillColor: Colors.green,
              constraints: BoxConstraints.tight(Size(35.0, 35.0)),
              child: Center(

                child: IconButton(
                  padding: EdgeInsets.all(3.0),
                  icon: Icon(Icons.search),
                ),
              )),
          RawMaterialButton(
              shape: const CircleBorder(),
              fillColor: Colors.green,
              constraints: BoxConstraints.tight(Size(35.0, 35.0)),
              child: Center(
                
                child: IconButton(
                  padding: EdgeInsets.all(3.0),
                  icon: Icon(Icons.play_arrow),
                ),
              )),
          RawMaterialButton(
              shape: const CircleBorder(),
              fillColor: Colors.green,
              constraints: BoxConstraints.tight(Size(35.0, 35.0)),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.all(3.0),
                  icon: Icon(Icons.refresh),
                ),
              )),
              ],
            ),
          ),

          Container(
            height: 35.0,
            margin: EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 0.0),
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
            child: Row(
              children: <Widget>[
                Text(
                  "التفسير",
                ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
            decoration: new BoxDecoration(
              color: Colors.green,

              borderRadius: new BorderRadius.circular(15.0),
              //color: Colors.black
            ),
          ),
        ],
      ),
    );
  }

  Widget secondRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            height: 35.0,
            child: Row(

              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 9.5, 0.0),
                  child: Text("خطأ الحفظ"),
                ),
                Container(
                  constraints: BoxConstraints.tight(Size(10.0, 10.0)),
                  decoration: new BoxDecoration(
              
                    border: Border.all(
                      color:
                          Colors.red, //                   <--- border color
                      width: 8.5,
                    ),

                    borderRadius: new BorderRadius.circular(50.0),
                    //color: Colors.black
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 9.5, 0.0),
                  child: Text("خطأ التجويد"),
                ),
                Container(
                  constraints: BoxConstraints.tight(Size(10.0, 10.0)),
                  decoration: new BoxDecoration(
                    border: Border.all(
                      color:
                          Colors.yellow, //                   <--- border color
                      width: 8.5,
                    ),

                    borderRadius: new BorderRadius.circular(30.0),
                    //color: Colors.black
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 9.5, 0.0),
                  child: Text("تعليق"),
                ),
                Container(
                 constraints: BoxConstraints.tight(Size(10.0, 10.0)),
                  decoration: new BoxDecoration(
              
                    border: Border.all(
                      color:
                          Colors.blue, //                   <--- border color
                      width: 8.5,
                    ),

                    borderRadius: new BorderRadius.circular(30.0),
                    //color: Colors.black
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        //width: double.infinity,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            firstRow(),
            Divider(),
            secondRow(),
          ],
        ),
      ),
    );
  }
}
