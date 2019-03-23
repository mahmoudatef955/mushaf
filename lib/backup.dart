import 'package:flutter/material.dart';
import 'getImage.dart';
import 'SuraResult.dart';
import 'sqliteLoad.dart';
import 'dart:async';
import 'AyaResult.dart';



class mushaf extends StatefulWidget {
  mushafState createState() => mushafState();
}

class mushafState extends State<mushaf> {
  bool _showbar = true;
  int pageNo = 1;

  void _togglebar() {
    setState(() {
      _showbar = !_showbar;
    });
  }

   void callback(int index) {
    setState(() {
      this.pageNo =index;
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
            child: customAppBar(callback: this.callback),
            opacity: _showbar ? 1.0 : 0.0,
            //duration: Duration(milliseconds: 500),
          ),
          _showbar
              ? customButtomBar()
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
          _showbar
              ? copyIcon()
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
        ],
      ),
    );
  }

  Widget copyIcon() {
    return Positioned(
      left: 1.0,
      top: 160.0,
      child: Container(
          height: 45.0,
          width: 40.0,
          color: Colors.white,
          child: Icon(Icons.content_copy, color: Colors.teal[600], size: 27.0)),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                                                              ///
///                                     Custom AppBar                                            ///
///                                                                                              ///
///                                                                                              ///
/////////////////////////////////////////////////////////////////////////////////////////////////////
class customAppBar extends StatefulWidget {
  customAppBarState createState() => customAppBarState();
  Function callback;
  customAppBar({this.callback});
  
}

class customAppBarState extends State<customAppBar> {
  //int suraNO = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      //padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      height: 100.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SizedBox(width: 4.0),
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  
                  Icons.note_add,
                  color: Colors.teal[600],
                ),
                Text("فاصل جديد"),
                SizedBox(height: 4.0)
              ],
            ),
          ),
          SizedBox(
            width: 1.0,
          ),
          Container(
              margin: EdgeInsets.only(top: 23.0, right: 8.0),
              height: 80.0,
              width: 0.5,
              color: Colors.black87),
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Colors.teal[600],
                ),
                Text("الفواصل"),
                SizedBox(height: 4.0)
              ],
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          Container(
              margin: EdgeInsets.only(top: 23.0),
              height: 80.0,
              width: 0.5,
              color: Colors.black87),
          SizedBox(width: 85.0),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: GestureDetector(
                  onTap: _showDialog,
                  child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 28.0,
                  color: Colors.teal[600],
                ),
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 26.0, right: 42.0),
                      child: Text(
                        "الفاتحة",
                        style: TextStyle(fontSize: 18.0),
                      )),
                  Container(
                      padding: EdgeInsets.only(top: 0.0, right: 42.0),
                      child: Text(
                        "الاية 1",
                        style: TextStyle(fontSize: 18.0),
                      )),
                ],
              ),
              _drawer(context),
            ],
          ),
        ],
      ),
      /* Positioned(
            right: 50.0,
            bottom: 2.0,
            child: Text(
              "الآيه ١",
              style: TextStyle(fontSize: 17.0),
            ),
          ) */
    );
  }

void _showDialog(){
  
  //var ayaList = widget.db.getSuraTable();
  //print(jsonEncode(ayaList));
  showDialog(
    context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         content: dynamicDialog(callback: this.widget.callback),
         //suraList(dbHelper)
       );
     }
  );
}







}

  Widget _drawer(BuildContext context) {
    return Container(
      width: 40.0,
      height: 50.0,
      child: IconButton(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
        icon: Icon(
          Icons.menu,
          color: Colors.teal[600],
          size: 45.0,
        ),
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      ),
    );
  }


///////////////////////////////////////////////////////////////////////////////////////////////
///

class customButtomBar extends StatefulWidget {
  customButtomBarState createState() => customButtomBarState();
}

class customButtomBarState extends State<customButtomBar> {
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

  Widget firstRow() {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 13.0, 0.0, 0.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(width: 1.0),

          //القارئ
          Container(
            height: 35.0,
            width: 90.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.blueGrey[500]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 3.0),
                Text(
                  "الحذيفي",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.person, color: Colors.white)
              ],
            ),
          ),

          Row(
            children: <Widget>[
              //Search Icon
              CircleAvatar(
                  child: Icon(Icons.search, color: Colors.white),
                  maxRadius: 17.0,
                  backgroundColor: Colors.teal[600]),

              SizedBox(width: 7.0),

              //Play Icon
              CircleAvatar(
                  child: Icon(Icons.play_arrow, color: Colors.white),
                  maxRadius: 17.0,
                  backgroundColor: Colors.teal[600]),

              SizedBox(width: 7.0),

              //Repeat Icon
              CircleAvatar(
                  child: Icon(Icons.autorenew, color: Colors.white),
                  maxRadius: 17.0,
                  backgroundColor: Colors.teal[600]),

              SizedBox(width: 7.0),
            ],
          ),

          //التفسير
          Container(
            height: 35.0,
            width: 90.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.blueGrey[500]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 6.0),
                Text(
                  "التفسير",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.edit, color: Colors.white)
              ],
            ),
          ),
          SizedBox(width: 1.0)
        ],
      ),
    );
  }

  Widget secondRow() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      color: Colors.grey[300].withAlpha(150),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(width: 1.0),

          //خطأ حفظ
          Row(
            children: <Widget>[
              Text(
                "خطأ حفظ",
                style: TextStyle(color: Colors.blueGrey, fontSize: 17.0),
              ),
              SizedBox(width: 6.0),
              Icon(Icons.radio_button_unchecked,
                  color: Colors.orange[800], size: 17.0),
            ],
          ),
          //خطأ تجويد
          Row(
            children: <Widget>[
              Text(
                "خطأ تجويد",
                style: TextStyle(color: Colors.blueGrey, fontSize: 17.0),
              ),
              SizedBox(width: 6.0),
              Icon(Icons.radio_button_unchecked,
                  color: Colors.yellow[800], size: 17.0),
            ],
          ),

          //تعليق
          Row(
            children: <Widget>[
              Text(
                "تعليق",
                style: TextStyle(color: Colors.blueGrey, fontSize: 17.0),
              ),
              SizedBox(width: 6.0),
              Icon(Icons.radio_button_unchecked,
                  color: Colors.blue[800], size: 17.0),
            ],
          ),

          SizedBox(width: 1.0),
        ],
      ),
    );
  }
}


class dynamicDialog extends StatefulWidget{
  dynamicDialogState createState() => dynamicDialogState();
  Function callback;
  dynamicDialog({this.callback});
  //DBHelper dbHelper;

}

class dynamicDialogState extends State<dynamicDialog>{
  DBHelper dbHelper =DBHelper();
  int suraNO;
  @override
  Widget build(BuildContext context) {

    void select(){
      setState(() {
        
      });
    }
    // TODO: implement build

    return Container(
           height: 370.0,
           child: Column(
             children: <Widget>[
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: <Widget>[
                   
                   ayaList(dbHelper,suraNO),
                   suraList(dbHelper),
                 ],
               ),
               Container(
                 child: RaisedButton(
                   child: Text('اختيار'),
                   color: Colors.teal[600],
                   //onPressed: this.widget.callback(20),
                 ),
               ),       

             ],
           ),
         );
  }


  Widget suraList(DBHelper dbHelper){
  
  return FutureBuilder<List<SuraResult>>(
        future: dbHelper.getSuraTable(),
        builder: (BuildContext context, AsyncSnapshot<List<SuraResult>> snapshot) {
          
          if (snapshot.hasData) {
            return Container(
              width: 110.0,
              height: 290.0,
              child: ListView.builder(
              
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                SuraResult item = snapshot.data[index];
                
                return ListTile(                 
                  onTap: () => setState(() => suraNO = index+1),
                  title: Text(item.name.toString()),
                                  
                );
              },
            ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
}

Widget ayaList(DBHelper dbHelper,int suraNO){
 
  return FutureBuilder<List<AyaResult>>(
        future: dbHelper.getAyaTable(suraNO),
        builder: (BuildContext context, AsyncSnapshot<List<AyaResult>> snapshot) {
          
          if (snapshot.hasData) {
            return Container(
              width: 110.0,
              height: 290.0,
              child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                AyaResult item = snapshot.data[index];
                
                return ListTile(
                  title: Text(item.aya.toString()),
                  //selected: ,
                                  
                );
              },
            ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
}

}
