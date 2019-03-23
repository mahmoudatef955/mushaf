import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:image/image.dart' as Image;
//import 'package:http/http.dart' as http;




class loadImage extends StatefulWidget{
  final pageNo;

  loadImage({this.pageNo});
  loadImageState createState()=> loadImageState();
}


class loadImageState extends State<loadImage> {
  dynamic _imageFile;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


  Future<File> getImageFromNetwork(String url) async {
    var cacheManager = await CacheManager.getInstance();
    //File file = await cacheManager.getFile(url);
    File file = await cacheManager.getFile(url);
    return file;
  }


  Future<File>saveImage(int i) async {
    String url = 'http://quran.gplanet.tech/hafs/images/${i+1}.png';
    final file = await getImageFromNetwork(url);
    //retrieve local path for device
    var path = await _localPath;
    var image = Image.decodeImage(file.readAsBytesSync());

    var thumbnail = Image.copyResize(image, 120);

    // Save the thumbnail as a PNG.
    File('$path/${i+1}.png').writeAsBytesSync(Image.encodePng(image));
    return  File('$path/${i+1}.png')
      ..writeAsBytesSync(Image.encodePng(thumbnail));
    //print('$path/$i.png');
/*
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file1 = new File('$dir/${i+1}.png');
    var request = await http.get(url,);
    var bytes = await request.bodyBytes;//close();
    await file1.writeAsBytes(bytes);
    print('Save new file un =>>>>>   '+file1.path); */

  }

  void printPath() async {
    var path = await _localPath;
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(path);
  }

  Future<File> openImage(int i) async {
    var path = await _localPath;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File image;
    File file = new File('$dir/$i.png');
    if (file.existsSync()) {}
    try {
      //image = Image.decodeImage(new File('$path/$i.png').readAsBytesSync());
      //image = new File('$path/$i.png');
      image = File('$dir/${i+1}.png');
    } catch (e) {
      // If encountering an error, return 0
      saveImage(i);
      try {
        //image = Image.decodeImage(new File('$path/$i.png').readAsBytesSync());
        image = new File('$dir/$i+1.png');
      } catch (e) {
        // If encountering an error, return 0
        print('error getting image');
      }
    }

    print('open from:   ' + path+'$i');
    return image;
  }

////////////////////////////////////////////////////////


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image:new CachedNetworkImageProvider('http://quran.gplanet.tech/hafs/images/${widget.pageNo + 1}.png')
              /* NetworkImage(
                  'http://quran.gplanet.tech/hafs/images/${widget.pageNo + 1}.png')*/
                  )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new RaisedButton(
            onPressed: () {
              //audioCache.play('1.mp3');
            },
          ),
        ],
      ),
    );
  }
}
