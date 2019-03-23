import 'package:flutter/material.dart';
import 'sura.dart';
import 'dart:async';
import 'loadImage.dart';
import 'package:image/image.dart' as Image;
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';



import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Future<Null> _launched;

  Widget _showResult(BuildContext context, AsyncSnapshot<Null> snapshot) {
    if (!snapshot.hasError) {
      return Text('Image is saved');
    } else {
      return const Text('Unable to save image');
    }
  }

  Future<Null> _saveNetworkImage(String url) async {
    try {
      await SaveFile().saveImage(url);
    } on Error catch (e) {
      throw 'Error has occured while saving';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Image'),
      ),
      body: Column(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                setState(() {
                  _launched = _saveNetworkImage(
                      'http://quran.gplanet.tech/hafs/images/20.png');
                });
              }),
          new FutureBuilder<Null>(future: _launched, builder: _showResult),
        ],
      ),
    );
  }
}

class SaveFile {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<Io.File> getImageFromNetwork(String url) async {
    var cacheManager = await CacheManager.getInstance();
    Io.File file = await cacheManager.getFile(url);
    return file;
  }

  Future<Io.File> saveImage(String url) async {
    final file = await getImageFromNetwork(url);
    //retrieve local path for device
    var path = await _localPath;
    Image.Image image = Image.decodeImage(file.readAsBytesSync());

    Image.Image thumbnail = Image.copyResize(image, 120);

    // Save the thumbnail as a PNG.
    return new Io.File('$path/${20}.png')
      ..writeAsBytesSync(Image.encodePng(thumbnail));
  }
}

/////////////////////////////////////////////////
class NetworkToLocalImage extends StatefulWidget{
    String url1;
    final pageNo=1;
    dynamic imageFile ;//= AssetImage('assets/images/1.jpg') ;
    NetworkToLocalImage();
    //NetworkToLocalImage({this.url1});

  LoadImages createState()=> LoadImages(pageNo);
}

class LoadImages extends State<NetworkToLocalImage> {
  String url;
  String filename;
  var dataBytes;
  

  LoadImages(int i) {
    url='http://quran.gplanet.tech/hafs/images/${i}.png';
    filename = Uri.parse(url).pathSegments.last;
    downloadImage(i).then((bytes) {
      setState(() {
        dataBytes = bytes;
        widget.imageFile = bytes;
        //Image.Image _receiptImage = Image.decodeImage(new Io.File(mImagePath).readAsBytesSync());

         print('Changed');
      });
      
    });
    var bytes = downloadImage(i);
    setState(() {
        dataBytes = bytes;
        widget.imageFile = bytes;
         print('Changed');
      });
    }

Future<Image.Image> openImage(int i)async{
  String dir = (await getApplicationDocumentsDirectory()).path;
    Io.File file = new Io.File('$dir/$i.png');
    if (file.existsSync()) {}
}


  Future<dynamic> downloadImage(int i) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    Io.File file = new Io.File('$dir/$i.png');

    if (file.existsSync()) {
      print('file already exist');
      var image = await file.readAsBytes();
      return image;
    } else {
      print('file not found downloading from server');
      var request = await http.get(url);
      var bytes = await request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print(file.path);
      return bytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
     LoadImages(100);
    if (true)//dataBytes != null)
      return Scaffold(
        //drawer: widget.drawer,
        appBar: AppBar(
          title: Text("surah"),
        ),
        body: Swiper(
          itemCount: 100,
          itemBuilder: (context, i) {
            LoadImages(i);
            return  Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image:// widget.imageFile,
              
              NetworkImage(
                  'http://quran.gplanet.tech/hafs/images/${i}.png')
                  
                  )
                  ), 
                  
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new RaisedButton(
            onPressed: () {
              LoadImages(i);
              //audioCache.play('1.mp3');
            },
          ),
        ],
      ),
    );;
          },
        )); 
      //new Image.Image.memory(dataBytes);
    else{
      LoadImages(20);
      return new CircularProgressIndicator();
    }
  }
}





       