import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AyaResult.dart';
import 'package:carousel_pro/carousel_pro.dart';

class getImage extends StatefulWidget {
  //String url = 'http://quran.gplanet.tech/hafs/images/10.png';
  int pageNo = 1;
  var imageFile;
  Future<MemoryImage> _future;
  List<MemoryImage> imageList = new List<MemoryImage>(604);

  getImage({this.pageNo});

  getImageState createState() => getImageState();
}

class getImageState extends State<getImage> {
  // final AsyncMemoizer _memoizer = AsyncMemoizer();

  /* Future<MemoryImage> open(int i) async {
    
    final Uint8List bytes = await downloadImage(i);
    if (bytes.lengthInBytes == 0) return null;

    return MemoryImage(bytes);
  } */

  Future<MemoryImage> downloadImage(int i) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String url = 'http://quran.gplanet.tech/hafs/images/${i}.png';
    Io.File file = new Io.File('$dir/$i.png');

    if (file.existsSync()) {
      print('file already exist');
      var image = await file.readAsBytes();
      return MemoryImage(image);
    } else {
      print('file not found downloading from server');
      var request = await http.get(url);
      var bytes = await request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print(file.path);
      //return bytes;
      final Uint8List bytes1 = bytes;
      if (bytes.lengthInBytes == 0) return null;

      return MemoryImage(bytes1);
    }
  }

  void downloadAllImage() async {
    for (int i = 0; i <= 604; i++) {
      this.widget.imageList.add(await downloadImage(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (true) {
      //dataBytes != null)
      return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
        return Scaffold(
            //drawer: widget.drawer,

            body: Swiper(
          itemCount: 604,
          index: model.aya.page, //this.widget.pageNo,
          control: new SwiperControl(),
          itemBuilder: (context, i) {
            return new FutureBuilder<MemoryImage>(
              future: downloadImage(i), //open(i),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ); // or some other placeholder
                return new Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: snapshot.data, //new FileImage(snapshot.data),
                    fit: BoxFit.fill,
                  )),
                );
              },
            );
          },
        ));
      });
    }
    //new Image.Image.memory(dataBytes);
    else {
      return new CircularProgressIndicator();
    }
  }
}

class pages {
  List<MemoryImage> imageList = new List<MemoryImage>(604);

  Future<MemoryImage> downloadImage(int i) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String url = 'http://quran.gplanet.tech/hafs/images/${i}.png';
    Io.File file = new Io.File('$dir/$i.png');

    if (file.existsSync()) {
      print('file already exist');
      var image = await file.readAsBytes();
      return MemoryImage(image);
    } else {
      print('file not found downloading from server');
      var request = await http.get(url);
      var bytes = await request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print(file.path);
      //return bytes;
      final Uint8List bytes1 = bytes;
      if (bytes.lengthInBytes == 0) return null;

      return MemoryImage(bytes1);
    }
  }

  void downloadAllImage() async {
    for (int i = 0; i <= 604; i++) {
      MemoryImage img = await downloadImage(i);
      this.imageList[i] = img;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////////
///
///
/////////////////////////////////////////////////////////////////////////////////
///

class ImageCarousel extends StatefulWidget {
  pages pageList = new pages();
  AyaList model;
  ImageCarousel({this.model});

  _ImageCarouselState createState() => new _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with SingleTickerProviderStateMixin {
  MemoryImage img;
  int pageNO;
  Future<MemoryImage> futureImage;
  PageController controller = PageController(
    initialPage: 1,
  );

    Future<MemoryImage> downloadImage(int i) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String url = 'http://quran.gplanet.tech/hafs/images/${i}.png';
    Io.File file = new Io.File('$dir/$i.png');

    if (file.existsSync()) {
      print('file already exist');
      var image = await file.readAsBytes();
      return MemoryImage(image);
    } else {
      print('file not found downloading from server');
      var request = await http.get(url);
      var bytes = await request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print(file.path);
      //return bytes;
      final Uint8List bytes1 = bytes;
      if (bytes.lengthInBytes == 0) return null;

      return MemoryImage(bytes1);
    }
  }

  void jump(int currentIndex,int modelIndex){
    if(currentIndex !=modelIndex){
      controller.jumpToPage(modelIndex);
    }
  }

  



  @override
void initState() {
  super.initState();
  pageNO = this.widget.model.aya.page;
   futureImage =downloadImage(pageNO);// only create the future once.
  
}

  @override
  Widget build(BuildContext context) {
        return ScopedModelDescendant<AyaList>(
      builder: (context, child, model){
        //model.addListener((){jump(1,model.aya.page);});
    return Scaffold(
      body: PageView.builder(
        controller: controller,        
        onPageChanged: (int index){
          model.changepage(index);
          setState(() {
            pageNO =index;
            futureImage =downloadImage(pageNO);
          });
          print('index>>>>>>>>>>>>>>>>$index');
        },
        
        itemBuilder: (context, position) {
         return FutureBuilder<MemoryImage>(
              future: futureImage, 
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ); // or some other placeholder
                return new Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: snapshot.data, //new FileImage(snapshot.data),
                    fit: BoxFit.fill,
                  )),
                );
              },
            );
          
        },
      ),
    );
    
      } 
    );
  }
}

/* FutureBuilder<MemoryImage>(
              future: this.widget.pageList.downloadImage(position), //open(i),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ); // or some other placeholder
                return new Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: snapshot.data, //new FileImage(snapshot.data),
                    fit: BoxFit.fill,
                  )),
                );
              },
            ); */

class ImagePageView extends StatelessWidget{

  pages pageList = new pages();
  MemoryImage img;
  PageController controller = PageController(
    initialPage: 1,
  );

  void loadImage(int i) async {
    img = await this.pageList.downloadImage(i);
  }

   Future<MemoryImage> downloadImage(int i) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    String url = 'http://quran.gplanet.tech/hafs/images/${i}.png';
    Io.File file = new Io.File('$dir/$i.png');

    if (file.existsSync()) {
      print('file already exist');
      var image = await file.readAsBytes();
      return MemoryImage(image);
    } else {
      print('file not found downloading from server');
      var request = await http.get(url);
      var bytes = await request.bodyBytes; //close();
      await file.writeAsBytes(bytes);
      print(file.path);
      //return bytes;
      final Uint8List bytes1 = bytes;
      if (bytes.lengthInBytes == 0) return null;

      return MemoryImage(bytes1);
    }
  }



  @override
  Widget build(BuildContext context) {
        return ScopedModelDescendant<AyaList>(
      builder: (context, child, model){
        //model.addListener((){jump(1,model.aya.page);});
    return Scaffold(
      body: PageView.builder(
        controller: controller,        
        onPageChanged: (int index){
          model.changepage(index);
          print('index>>>>>>>>>>>>>>>>$index');
        },
        
        itemBuilder: (context, position) {
          //loadImage(position);
          FutureBuilder<MemoryImage>(
              future: downloadImage(position), //open(i),
              builder: (context, snapshot) {
                if (snapshot.hasData != null)
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ); // or some other placeholder
                return new Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    image: snapshot.data, //new FileImage(snapshot.data),
                    fit: BoxFit.fill,
                  )),
                );
              },
            );
        },
      ),
    );
    
      } 
    );
  }
  
}