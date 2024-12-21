import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class AppSecureCache {
  Future<void> set(String key, dynamic value);

  Future<T?> get<T>(String key);

  Future<bool> has(String key);

  Future<void> clear(String key);
}

@LazySingleton(as: AppSecureCache)
class AppCacheSecureImpl implements AppSecureCache {
  AppCacheSecureImpl();

  final storage = const FlutterSecureStorage();

  @override
  Future<bool> has(String key) async {
    return (await storage.read(key: key)) != null;
  }

  @override
  Future<void> clear(String key) async {
    await storage.delete(key: key);
  }

  @override
  Future<T?> get<T>(String key) async {
    final value = await storage.read(key: key);
    if (value != null) {
      return value as T;
    } else {
      return null;
    }
  }

  @override
  Future<void> set(String key, dynamic value) async {
    await storage.write(key: key, value: value);
  }
}
