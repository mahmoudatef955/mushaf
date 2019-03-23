import 'package:scoped_model/scoped_model.dart';
import 'SuraResult.dart';

/*
  * Author: Karim Mohamed
  * Email: karimmohamed200510@gmail.com
  * Date: 21/1/2019
  * Function: Aya Model
*/
class AyaResult {
  dynamic _id;
  dynamic _sura;
  dynamic _aya;
  dynamic _text;
  dynamic _pure_text;
  dynamic _page;
  dynamic _amount;
  dynamic _guz;
  dynamic _x;
  dynamic _y;
  dynamic _tafseer;
  dynamic _xw;
  dynamic _yw;
  
  AyaResult(
      {dynamic id,
      dynamic sura,
      dynamic aya,
      dynamic text,
      dynamic pure_text,
      dynamic page,
      dynamic amount,
      dynamic guz,
      dynamic x,
      dynamic y,
      dynamic tafseer,
      dynamic xw,
      dynamic yw}) {
    this._aya = aya;
    this._id = id;
    this._page = page;
    this._tafseer = tafseer;
    this._x = x;
    this._xw = xw;
    this._yw = yw;
    this._y = y;
    this._amount = amount;
    this._guz = guz;
    this._pure_text = pure_text;
    this._text = text;
    this._sura = sura;
   
  }

  dynamic get aya => _aya;

  set aya(dynamic aya) => _aya = aya;
  dynamic get sura => _sura;

  set sura(dynamic sura) => _sura = sura;

  dynamic get id => _id;

  set id(dynamic id) => _id = id;
  dynamic get text => _text;

  set text(dynamic text) => _text = text;
  dynamic get pure_text => _pure_text;

  set pure_text(dynamic pure_text) => _pure_text = pure_text;

  dynamic get x => _x;

  set x(dynamic x) => _x = x;

  dynamic get y => _y;

  set y(dynamic y) => _y = y;

  dynamic get xw => _xw;

  set xw(dynamic xw) => _xw = xw;

  dynamic get yw => _yw;

  set yw(dynamic yw) => _yw = yw;

  dynamic get amount => _amount;

  set amount(dynamic amount) => _amount = amount;

  dynamic get tafseer => _tafseer;

  set tafseer(dynamic tafseer) => _tafseer = tafseer;

  dynamic get guz => _guz;

  set guz(dynamic guz) => _guz = guz;

  dynamic get page => _page;

  set page(dynamic page) => _page = page;

  AyaResult.fromJson(dynamic json) {
    _id = json['id'];
    _sura = json['sura'];
    _aya = json['aya'];
    _text = json['text'];
    _pure_text = json['pure_text'];

    _page = json['page'];
    _amount = json['amount'];
    _guz = json['guz'];

    _x = json['x'];
    _y = json['y'];
    _tafseer = json['tafseer'];
    _xw = json['xw'];
    _yw = json['yw'];
  }
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['id'] = this._id;
    data['aya'] = this._aya;
    data['amount'] = this._amount;
    data['xw'] = this._xw;
    data['pure_text'] = this._pure_text;
    data['x'] = this._x;
    data['y'] = this._y;
    data['yw'] = this._yw;
    data['tafseer'] = this._tafseer;
    data['text'] = this._text;
    data['guz'] = this._guz;
    data['sura'] = this._sura;
    data['page'] = this._page;
    return data;
  }
}

class AyaList extends Model {
  List<AyaResult> _ayaList;
  int index;
  
  AyaResult _aya;
 

  dynamic get aya => _aya;
  dynamic get ayalist => _ayaList;


  AyaList(List<AyaResult> ayaListI) {
    this._ayaList = ayaListI;
    index = 1;
    
    _aya = _ayaList[this.index];
    
  }

  AyaList.clone(AyaList ayalistI){
    this._ayaList = ayalistI._ayaList;
    _aya =ayalistI.aya;
  }

  void changeAya(int i) {
   _aya = _ayaList[i];
   index =_aya.id;
    notifyListeners();
  }


  void IncrementAya() {
   index++;
   _aya = _ayaList[index];   
    notifyListeners();
  }

  void changepage(int i) {
    

    _aya = _ayaList.firstWhere((aya) =>aya.page.toString()==i.toString(), orElse: () => _aya);
    index =_aya.id;
    notifyListeners();
    print('page----------------------'+_aya.page.toString());
  }

  void selectSura(int i) {

    _aya = _ayaList.firstWhere((aya) =>aya.sura.toString()==i.toString(), orElse: () => _aya);
    index =_aya.id;
    notifyListeners();
    print('sura----------------------'+_aya.sura.toString()+'page-----------'+_aya.page.toString());
  }

  int getPageBySura(int sura){
    AyaResult aya = _ayaList.firstWhere((aya) =>aya.sura.toString()==sura.toString(), orElse: () => _aya);
    index =_aya.id;
    return aya._page;
  }
}
