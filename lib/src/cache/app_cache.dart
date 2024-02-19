import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

abstract class AppCache {
  T? get<T>(String key);

  // Future<AppResponse<T>?>? getObjectFromJson<T extends BaseResponse<T>>({required dynamic object, required key});

  bool has(String key);

  void clear(String key);

  void set(String key, dynamic value);
}

@Injectable(as: AppCache)
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
}
