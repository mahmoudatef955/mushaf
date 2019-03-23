import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'sqliteLoad.dart';
import 'mushafPage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AyaResult.dart';
import 'SuraResult.dart';
import 'getImage.dart';



void main() => runApp(new MyApp());


class MyApp extends StatefulWidget{
  AyaResult aya;
  AyaList ayatable;
  List<SuraResult> suratable;

DBHelper dbHelper = DBHelper();


  MyAppState createState()=> MyAppState();
}

class MyAppState extends State<MyApp>{

  void syncDataBase() async{
    this.widget.ayatable = new AyaList(await this.widget.dbHelper.getAllAyaTable());
    this.widget.suratable = await this.widget.dbHelper.getAllSuraTable();
    setState(() {
      
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    syncDataBase();
   // this.widget.aya = this.widget.ayatable.ayalist[1];
    
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
        endDrawer: Container(width: 60.0, child: Drawer()),
        body:this.widget.ayatable != null ?
        ScopedModel<AyaList>(
          model: this.widget.ayatable,
          child: mushaf(ayatable1: this.widget.ayatable,suratable: this.widget.suratable,),
        )
        :Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
    
        ),
      ),
    );
  }
} 
