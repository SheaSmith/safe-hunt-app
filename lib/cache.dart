import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  SharedPreferences prefs;

  init() {
    SharedPreferences.getInstance().then((p) => prefs = p);
  }

  Future<dynamic> initAsync() async {
    prefs = await SharedPreferences.getInstance();
    return;
  }

  String getValue(String key) {
    var list = prefs.getStringList(key);
    if (list != null) {
      int expiry = int.parse(list[0]);

      if (expiry != -1 && expiry <= DateTime.now().millisecondsSinceEpoch)
        return null;
      else
        return list[1];
    }
    else {
      return null;
    }
  }

  putValue(String key, String value, {int expiry = -1}) {
    if (expiry != null && expiry != -1)
      expiry = expiry + DateTime.now().millisecondsSinceEpoch;

    prefs.setStringList(key, [expiry.toString(), value]);
  }

  bool hasValue(String key) {
    if (prefs.getStringList(key) != null) {

      int expiry = int.parse(prefs.getStringList(key)[0]);

      if (expiry == -1 || expiry > DateTime.now().millisecondsSinceEpoch)
        return true;
    }

    return false;
  }
}