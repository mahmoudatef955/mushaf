import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'getImage.dart';
import 'SuraResult.dart';
import 'sqliteLoad.dart';
import 'dart:async';
import 'AyaResult.dart';
//import 'audioPlayer.dart';
import 'package:audioplayer/audioplayer.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'dart:typed_data';

enum PlayerState { stopped, playing, paused }
typedef void OnError(Exception exception);

class mushaf extends StatefulWidget {
  AyaList ayatable1;
  List<SuraResult> suratable;
  mushaf({this.ayatable1, this.suratable});
  mushafState createState() => mushafState();
}

class mushafState extends State<mushaf> {
  DBHelper dbHelper = DBHelper();
  AyaList ayatablerepeat;
void syncDataBase() async{
    this.ayatablerepeat = new AyaList(await this.dbHelper.getAllAyaTable());
    //this.widget.suratable = await this.widget.dbHelper.getAllSuraTable();
    setState(() {
      
    });
  }
  bool _showbar = true;
  int pageNo = 2;
  AudioPlayer audioPlugin = new AudioPlayer();
  String kUrl = "http://quran.gplanet.tech/hafs/sound/sudais/001002.mp3";
  String kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  int noOfAya = 1;
  int noOfSura = 1;
  int index = 1;

  AyaList ayatable;

  void playPage(AyaList model) async {
    ayatable = model;
    noOfSura = model.aya.sura;
    noOfAya = model.aya.aya;
    print('play page>>>>>>>>>>>>>>>>$noOfAya>>>>>>>>>>>>>>>>>');
    play(noOfSura, noOfAya);
    /*
    ScopedModelDescendant<AyaList>(
                builder: (context, child, model) {
    //noOfSura = this.widget.ayatable.ayaList[index].sura;
    //noOfAya = this.widget.ayatable.ayaList[index].aya;
    
                }
    ); */
  }

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    syncDataBase();
    pageNO = this.widget.ayatable1.aya.page;
    futureImage = downloadImage(pageNO);
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() async {
    this.widget.ayatable1 = AyaList(await dbHelper.getAllAyaTable());
    //await dbHelper.getAllAyaTable(this.pageNo);
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play(int sura, int aya) async {
    //await audioPlayer.play("http://quran.gplanet.tech/hafs/sound/sudais/00100"+noOfAya.toString()+".mp3");
    String suraNO, ayaNO;
    if (sura < 10)
      suraNO = "00" + sura.toString();
    else if (sura < 100)
      suraNO = "0" + sura.toString();
    else
      suraNO = sura.toString();

    if (aya < 10)
      ayaNO = "00" + aya.toString();
    else if (aya < 100)
      ayaNO = "0" + aya.toString();
    else
      ayaNO = aya.toString();

    print("----------" + suraNO + "---------------" + ayaNO);

    await audioPlayer.play("http://quran.gplanet.tech/hafs/sound/sudais/" +
        suraNO +
        ayaNO +
        ".mp3");
    //await audioPlayer.play("http://quran.gplanet.tech/hafs/sound/sudais/00100"+"1"+".mp3");

    print("-----played-----" + suraNO + "---------------" + ayaNO);

    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future _playLocal() async {
    await audioPlayer.play(localFilePath, isLocal: true);
    setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() {
      playerState = PlayerState.stopped;
    });
    //play();
    print(">>>>>>>>>>>>>>>>>>>>>>teststssddc<<<<<<<<<<<<<<<<<<<<<<<<");
    noOfAya++;
    index++;
    //noOfSura = this.widget.ayatable.ayalist[index].sura;
    //noOfAya = this.widget.ayatable.ayalist[index].aya;

    ayatable.IncrementAya();
    noOfSura = ayatable.aya.sura;
    noOfAya = ayatable.aya.aya;
    print('page No    $pageNO  >>>>>>>>>>> $this.ayatable.aya.page');
    if (pageNo != this.ayatable.aya.page) {
      setState(() {
        //pageNo = this.widget.ayatable.ayalist[index].page;
        jump(this.ayatable.aya.page);
      });
    }
    print('call play on >>>> $noOfSura >>>> $noOfAya');
    play(noOfSura, noOfAya);
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    final bytes = await _loadFileBytes(kUrl,
        onError: (Exception exception) =>
            print('_loadFile => exception $exception'));

    final dir = await getApplicationDocumentsDirectory();
    final file = new File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
      });
  }

  void playpress() {
    //_loadFile();
    //_playLocal();
    //play();
  }

  void _togglebar() {
    setState(() {
      _showbar = !_showbar;
    });
  }

///////////////////////////////////////////////////
  ///
  ///         Image
  ///
//////////////////////////////////////////////////
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

  void jump(int modelIndex) {
    controller.jumpToPage(modelIndex);
  }

  Widget mushafPageImage() {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      //model.addListener((){jump(1,model.aya.page);});
      return Scaffold(
        body: PageView.builder(
          scrollDirection: Axis.horizontal,
          reverse: true,
          controller: controller,
          onPageChanged: (int index) {
            model.changepage(index);
            setState(() {
              pageNO = index;
              futureImage = downloadImage(pageNO);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            child: ScopedModelDescendant<AyaList>(
                builder: (context, child, model) {
              return mushafPageImage(); //ImageCarousel(model: model,);
            }),
            onTap: _togglebar,
          ),
          Opacity(
            child: ScopedModelDescendant<AyaList>(
                builder: (context, child, model) {
              return customAppBar1();
            }),
            opacity: _showbar ? 1.0 : 0.0,
            //duration: Duration(milliseconds: 500),
          ),
          _showbar
              ? customButtomBar1()
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

  Widget customAppBar1() {
    return ScopedModelDescendant<AyaList>(
      builder: (context, child, model) {
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
                      onTap: //_showDialog,
                          () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: //dynamicDialog(parent: this),
                                    ScopedModel<AyaList>(
                                        //mushaf()
                                        model: model,
                                        child: model != null
                                            ? dynamicDialog(
                                                parent: this,
                                                suraList1:
                                                    this.widget.suratable,
                                              )
                                            : Container(
                                                height: 370.0,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )),
                              );
                            });
                      },
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
                            //"hg",
                            this.widget.suratable[model.aya.sura - 1].name,
                            style: TextStyle(fontSize: 18.0),
                          )),
                      Container(
                          padding: EdgeInsets.only(top: 0.0, right: 42.0),
                          child: Text(
                            //"الاية 1",
                            model.aya.aya.toString(),
                            style: TextStyle(fontSize: 18.0),
                          )),
                    ],
                  ),
                  _drawer(context),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog() {
    print('--------show dialog');
    ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: //dynamicDialog(parent: this),
                  ScopedModel<AyaList>(
                      //mushaf()
                      model: model,
                      child: model != null
                          ? dynamicDialog(
                              parent: this,
                              suraList1: this.widget.suratable,
                            )
                          : Container(
                              height: 370.0,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )),
            );
          });
    });
    /* showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: //dynamicDialog(parent: this),
            ScopedModel<AyaList>(
          //mushaf()
          model: this.widget.ayatable,
          child: this.widget.ayatable != null ? 
          dynamicDialog(parent: this,suraList1: this.widget.suratable,)
          : Container(
      height: 370.0,
      child: Center(
                      child: CircularProgressIndicator(),
                    ),
    )
        ),
          );
        }); */
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

  Widget repeatDialog() {
    return RepeatDialog();
  }

  Future _showRepeateDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return RepeatDialog();
        });
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  //////////////////////////////////////////////////////////////////////////////////////

  Widget customButtomBar1() {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
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
    });
  }

  Widget firstRow() {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
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
                  Icon(Icons.person, color: Colors.white),
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
                    child: GestureDetector(
                      child: Icon(Icons.play_arrow, color: Colors.white),
                      onTap: () {
                        if (playerState == PlayerState.playing)
                          pause();
                        else
                          playPage(model);
                      },
                    ),
                    maxRadius: 17.0,
                    backgroundColor: Colors.teal[600]),

                SizedBox(width: 7.0),

                //Repeat Icon
                GestureDetector(
                  onTap: /* () {
                    _showRepeateDialog(context);
                  }, */
                   () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: //dynamicDialog(parent: this),
                                    ScopedModel<AyaList>(
                                        //mushaf()
                                        model: model,
                                        child: model != null
                                            ? //dynamicDialog(
                                              RepeatDialog(
                                                ayatable: ayatablerepeat,
                                                parent: this,
                                                suraList1:
                                                    this.widget.suratable,
                                              )
                                            : Container(
                                                height: 370.0,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )),
                              );
                            });
                      },
                  child: CircleAvatar(
                      child: Icon(Icons.autorenew, color: Colors.white),
                      maxRadius: 17.0,
                      backgroundColor: Colors.teal[600]),
                ),

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
                  GestureDetector(
                      child: Icon(Icons.edit, color: Colors.white),
                      onTap: () {
                        jump(20);
                      }),
                ],
              ),
            ),
            SizedBox(width: 1.0)
          ],
        ),
      );
    });
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

class dynamicDialog extends StatefulWidget {
  mushafState parent;
  List<SuraResult> suraList1;

  dynamicDialogState createState() => dynamicDialogState();

  dynamicDialog({this.parent, this.suraList1});
}

class dynamicDialogState extends State<dynamicDialog> {
  DBHelper dbHelper = DBHelper();
  int suraNO = 5;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      if (model != null) {
        suraNO = model.aya.sura;
        return Container(
          height: 370.0,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ayaList(dbHelper, suraNO, model),
                  suraList(),
                ],
              ),
              Container(
                child: RaisedButton(
                  child: Text('اختيار'),
                  color: Colors.teal[600],
                  onPressed: () {
                    print('------------select---------');
                    this.widget.parent.jump(model.aya.page);
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          height: 370.0,
        );
      }
    });
  }

  Widget suraList() {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      if (model != null) {
        return Container(
          width: 110.0,
          height: 290.0,
          child: ListView.builder(
            itemCount: this.widget.suraList1.length,
            itemBuilder: (BuildContext context, int index) {
              SuraResult item = this.widget.suraList1[index];

              return ListTile(
                selected: (index + 1) == model.aya.sura,
                onTap: () => setState(() {
                      this.suraNO = index + 1;
                      model.selectSura(index + 1);
                    }),
                title: Text(item.name.toString()),
              );
            },
          ),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });
  }

  Widget ayaList(DBHelper dbHelper, int suraNO, AyaList model) {
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
                  selected: (index + 1) == model.aya.aya,
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

////////////////////////////////////////////////////
///
///
///     Repeate Dialog
///
///////////////////////////////////////////////////

class RepeatDialog extends StatefulWidget {
  mushafState parent;
  AyaList ayatable;
  List<SuraResult> suraList1;

  RepeatDialog({this.parent, this.suraList1,this.ayatable});

  @override
  _RepeatDialogState createState() => _RepeatDialogState();
}

class _RepeatDialogState extends State<RepeatDialog> {
  
  
  AyaResult startRepeat;
  AyaResult endRepeat;
  int suraNO = 5;
  int repeatayaNO = 0;
  int repeatallNO = 0;
  int ayaWaitTime = 0;
  

  DBHelper dbHelper = DBHelper();
  

  @override
  void initState() {
    super.initState();
//syncDataBase();
    
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      if (model != null) {
        suraNO = model.aya.sura;
       AyaList modelClone = AyaList.clone(model);
        return  Container(
          height: 305.0,
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //تكرار الآيات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                          repeatayaNO++;
                        });
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          
                          backgroundColor: Colors.green.withGreen(200),
                          child: Icon(
                            
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 27.0,
                          )),
                      ),
                      SizedBox(width: 7.0),
                      Text(repeatayaNO.toString()),
                      SizedBox(width: 7.0),
                      GestureDetector(
                         onTap: (){
                          setState(() {
                          if(repeatayaNO==0){}
                          else{
                            repeatayaNO--;
                          }
                        });
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          backgroundColor: Colors.green.withGreen(200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.5, left: 1.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 27.0,
                            ),
                          )),
                      ),
                    ],
                  ),
                  Text(
                    "تكرار الآيات",
                    style: TextStyle(
                      color: Colors.teal[600],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.brown[200], width: 1.5),
                        borderRadius: BorderRadius.circular(7.0)),
                    padding: EdgeInsets.only(left: 5.0),
                    height: 35.0,
                    width: 150.0,
                    child:
                    GestureDetector(
                      onTap: (){
                        //fromMenue(this.ayatable);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: //dynamicDialog(parent: this),
                                    ScopedModel<AyaList>(
                                        //mushaf()
                                        model: model,
                                        child: model != null
                                            ? fromMenue(model)
                                            : Container(
                                                height: 370.0,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )),
                              );
                            });
                        print('tapped');
                        },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: Row(
                        
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                           Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                              size: 27.0,
                            ),
                            SizedBox(width: 30.0,),
                          Text(model.aya.aya.toString()),
                          SizedBox(width: 10.0,),
                          Text(this.widget.suraList1[model.aya.sura-1].name),
                          
                        ],
                      ),
                      )
                    ),
                  ), 
                  Text(
                    "من",
                    style: TextStyle(color: Colors.teal[600]),
                  ),
                ],
              ),

              SizedBox(height: 10.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.brown[200], width: 1.5),
                        borderRadius: BorderRadius.circular(7.0)),
                    padding: EdgeInsets.only(left: 5.0),
                    height: 35.0,
                    width: 150.0,
                    child: GestureDetector(
                      onTap: (){
                        //fromMenue(this.ayatable);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: //dynamicDialog(parent: this),
                                    toMenue(this.widget.ayatable),
                              );
                            });
                        print('tapped222222222222');
                        },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        child: Row(
                        
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                           Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                              size: 27.0,
                            ),
                            SizedBox(width: 40.0,),
                          Text(this.widget.ayatable.aya.aya.toString()),
                          SizedBox(width: 10.0,),
                          Text(this.widget.suraList1[this.widget.ayatable.aya.sura-1].name),
                          
                        ],
                      ),
                      )
                    ),
                  ),
                  Text(
                    "إلى",
                    style: TextStyle(color: Colors.teal[600]),
                  ),
                ],
              ),

              Divider(color: Colors.black),

              //تكرار النطاق
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            repeatallNO++;
                          });
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          backgroundColor: Colors.green.withGreen(200),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 27.0,
                          )),
                      ),
                      SizedBox(width: 7.0),
                      Text(repeatallNO.toString()),
                      SizedBox(width: 7.0),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                          if(repeatallNO==0){}
                          else{
                            repeatallNO--;
                          }
                        });
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          backgroundColor: Colors.green.withGreen(200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.5, left: 1.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 27.0,
                            ),
                          )),
                      ),
                    ],
                  ),
                  Text(
                    "تكرار النطاق",
                    style: TextStyle(
                      color: Colors.teal[600],
                    ),
                  ),
                ],
              ),

              Divider(color: Colors.black),

              Center(
                child: Text(
                  "تلاوة معلم",
                  style: TextStyle(
                      color: Colors.teal[600], fontWeight: FontWeight.bold),
                ),
              ),

              //زمن السكوت بين الآيات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            ayaWaitTime++;
                          });
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          backgroundColor: Colors.green.withGreen(200),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 27.0,
                          )),
                      ),
                      SizedBox(width: 7.0),
                      Text(ayaWaitTime.toString()),
                      SizedBox(width: 7.0),
                      GestureDetector(
                        onTap: (){
                          if(ayaWaitTime==0){}
                          else{
                            setState(() {
                              ayaWaitTime--;
                            });
                          }
                        },
                        child: CircleAvatar(
                          maxRadius: 14.0,
                          backgroundColor: Colors.green.withGreen(200),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1.5, left: 1.0),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 27.0,
                            ),
                          )),
                      ),
                    ],
                  ),
                  Text(
                    "زمن السكوت بين الآيات",
                    style: TextStyle(
                      color: Colors.teal[600],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 5.0),

              Center(
                child: RaisedButton(
                  child: Text(
                    "ابدأ التكرار",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.teal[600],
                  onPressed: () {},
                ),
              )
            ],
          ),
        );
      }
    });
  }

  Widget suraList() {
    return ScopedModelDescendant<AyaList>(builder: (context, child, model) {
      if (model != null) {
        return Container(
          width: 110.0,
          height: 290.0,
          child: ListView.builder(
            itemCount: this.widget.suraList1.length,
            itemBuilder: (BuildContext context, int index) {
              SuraResult item = this.widget.suraList1[index];

              return ListTile(
                selected: (index + 1) == model.aya.sura,
                onTap: () => setState(() {
                      this.suraNO = index + 1;
                      model.selectSura(index + 1);
                    }),
                title: Text(item.name.toString()),
              );
            },
          ),
        );
      } else {
        return Center(child: CircularProgressIndicator());
      }
    });
  }

  Widget ayaList(DBHelper dbHelper, int suraNO, AyaList model) {
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
                  selected: (index + 1) == model.aya.aya,
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


  Widget fromMenue(AyaList ayaResultList){
    return  Container(
          height: 370.0,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ayaList(dbHelper, suraNO, ayaResultList),
                  suraList(),
                ],
              ),
              Container(
                child: RaisedButton(
                  child: Text('اختيار'),
                  color: Colors.teal[600],
                  onPressed: () {
                    print('------------select---------');
                    this.widget.parent.jump(ayaResultList.aya.page);
                    setState(() {
                      this.startRepeat = ayaResultList.aya;
                    });
                  },
                ),
              ),
            ],
          ),
        
    );
  }

  

   Widget toMenue(AyaList ayaResultList){
    return  Container(
          height: 370.0,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ayaList2(dbHelper, suraNO, ayaResultList),
                  suraList2(ayaResultList),
                ],
              ),
              Container(
                child: RaisedButton(
                  child: Text('اختيار'),
                  color: Colors.teal[600],
                  onPressed: () {
                    print('------------select---------');
                    //this.widget.parent.jump(ayaResultList.aya.page);
                  },
                ),
              ),
            ],
          ),
        
    );
  }

  Widget suraList2(AyaList model) {

        return Container(
          width: 110.0,
          height: 290.0,
          child: ListView.builder(
            itemCount: this.widget.suraList1.length,
            itemBuilder: (BuildContext context, int index) {
              SuraResult item = this.widget.suraList1[index];

              return ListTile(
                selected: (index + 1) == this.widget.ayatable.aya.sura,
                onTap: () => setState(() {
                      this.suraNO = index + 1;
                      this.widget.ayatable.selectSura(index + 1);
                    }),
                title: Text(item.name.toString()),
              );
            },
          ),
        );
      }
    
  }

  Widget ayaList2(DBHelper dbHelper, int suraNO, AyaList model) {
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
                  selected: (index + 1) == model.aya.aya,
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

