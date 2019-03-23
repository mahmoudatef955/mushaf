import 'dart:async';
//import 'package:halaqatnew/Controller/localization.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'loadImage.dart';


/* 
  * Author: Karim Mohamed
  * Email: karimmohamed200510@gmail.com
  * Date: 21/1/2019
  * Function: Show Mus7af Page From Database
*/
class Sura extends StatefulWidget {
  final drawer, page, pageID, x, y, xw, yw;
 /** Sura(
      {@required this.page,
      this.pageID,
      this.drawer,
      this.x,
      this.y,
      this.xw,
      this.yw});**/
  @override
  _SuraState createState() => _SuraState();
}

enum PlayerState { stopped, playing, paused }

class _SuraState extends State<Sura> {
   Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;

  @override
  void initState(){
    super.initState();
    initPlayer();
  }

  void initPlayer(){
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    advancedPlayer.positionHandler = (p) => setState(() {
    _position = p;
    });
  }
  Future<dynamic> _createHalaqatDirectories() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Sound/';
    await Directory(dirPath).create(
      recursive: true,
    );
    final String filePath = '$dirPath/1.mp3';
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: widget.drawer,
        appBar: AppBar(
          title: Text("surah"),
        ),
        body: Swiper(
          itemCount: 100,
          itemBuilder: (context, i) {
            return loadImage(pageNo: i);
          },
        ));
  }
}
