import 'dart:convert';
// import 'package:an_core_network/an_core_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

abstract class AppCache {
  T? get<T>(String key);

  T? getObject<T>(dynamic object, key);

  bool has(String key);

  void clear(String key);

  void set(String key, dynamic value);

  void setObject(String key, dynamic value);
}

@LazySingleton(as: AppCache)
class AppCacheImpl implements AppCache {
  final SharedPreferences _sharedPreferences;

  AppCacheImpl(this._sharedPreferences);

  @override
  bool has(String key) {
    return (_sharedPreferences.containsKey(key) && _sharedPreferences.get(key) != null);
  }

  @override
  void clear(String key) {
    _sharedPreferences.remove(key);
  }

  @override
  T? get<T>(String key) {
    if (has(key)) {
      if (_sharedPreferences.getString(key)!.contains('|')) {
        return _sharedPreferences.getString(key)!.toString().replaceAll("\"", '') as T;
      }
      return jsonDecode(_sharedPreferences.getString(key)!);
    } else {
      return null;
    }
  }

  @override
  void set(String key, dynamic value) {
    _sharedPreferences.setString(key, jsonEncode(value));
  }

  @override
  void setObject(String key, dynamic object) async {
    try {
      //* Make sure `toJson` implements
      final parse = jsonEncode(await object.toJson());
      _sharedPreferences.setString(key, parse);
    } catch (e) {
      print(e);
    }
  }

  @override
  T? getObject<T>(dynamic object, key) {
    if (has(key)) {
      final jsonString = _sharedPreferences.getString(key);
      final jsonMap = jsonDecode(jsonString!);
      final response = object.fromJson(jsonMap);
      return response;
    } else {
      return null;
    }
  }
}
