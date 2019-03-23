import 'dart:convert';
import 'dart:io';
import 'SuraResult.dart';
import 'AyaResult.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';



/*
   * Author: Karim Mohamed
   * Email: karimmohamed200510@gmail.com
   * Function: Read From Sqlite File
*/
class DBHelper {
  static Database dbInstance;

  Future<Database> get db async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "copy_asset.db");

    await deleteDatabase(path);

    ByteData data =
        await rootBundle.load(join("assets", 'db', "halaqat.sqlite"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes);

    var db = await openDatabase(path, readOnly: true);

    return db;
  }

  Future<List<SuraResult>> getSuraTable() async {
    var dbConnection = await db;
    var res = await dbConnection.query('Sura');
    
    List<SuraResult> list =
        res.isNotEmpty ? res.map((c) => SuraResult.fromJson(c)).toList() : [];
    var encodedList = jsonEncode(list);
    //return jsonDecode(encodedList);
    return list;
  }

  Future<List<SuraResult>> getNoAya(int suraID) async {
    var dbConnection = await db;
    var res = await dbConnection.rawQuery('SELECT * FROM Aya WHERE sura = $suraID');
     List<int> l;
     int i = 1;

     //res.forEach((row) =>  l.add(1)); //print(row['aya']));

     //List ll = List.from(res['aya'].);

    
     //print(ll);
     
    
    List<SuraResult> list =
        res.isNotEmpty ? res.map((c) => SuraResult.fromJson(c)).toList() : [];
    var encodedList = jsonEncode(list);
    //return jsonDecode(encodedList);
    return list;
  }

  Future<List<AyaResult>> getAyaTable(suraID) async {
    var dbConnection = await db;
    var res =
        await dbConnection.rawQuery('SELECT * FROM Aya WHERE sura = $suraID');
    List<AyaResult> list =
        res.isNotEmpty ? res.map((c) => AyaResult.fromJson(c)).toList() : [];
    var encodedList = jsonEncode(list);
    //return jsonDecode(encodedList);
    return list;

  }

  

Future<List<AyaResult>> getAllAyaTable() async {
    var dbConnection = await db;
    var res =
        await dbConnection.rawQuery('SELECT * FROM Aya');
    List<AyaResult> list =
        res.isNotEmpty ? res.map((c) => AyaResult.fromJson(c)).toList() : [];
    var encodedList = jsonEncode(list);
    //return jsonDecode(encodedList);
    return list;

  }


Future<List<SuraResult>> getAllSuraTable() async {
    var dbConnection = await db;
    var res =
        await dbConnection.rawQuery('SELECT * FROM Sura');
    List<SuraResult> list =
        res.isNotEmpty ? res.map((c) => SuraResult.fromJson(c)).toList() : [];
    
    return list;

  }
  

  Future<dynamic> getPage(pageID) async {
    var dbConnection = await db;
    List aya =
        await dbConnection.rawQuery('SELECT * FROM Aya WHERE page = $pageID');
        
    return aya.toList();
  }
}
