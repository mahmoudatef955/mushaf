/*
  * Author: Karim Mohamed
  * Email: karimmohamed200510@gmail.com
  * Date: 21/1/2019
  * Function: Sura Model
*/
class SuraResult {
  dynamic _id;
  dynamic _name;
  SuraResult({dynamic id, dynamic name}) {
    this._id = id;
    this._name = name;
  }

  dynamic get id => _id;

  set id(dynamic id) => _id = id;

  dynamic get name => _name;

  set name(dynamic name) => _name = name;

 

  

  SuraResult.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
  }
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    return data;
  }
}
