// app_cache_secure_impl.dart
import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../services/app_encrypt_service.dart';
import 'app_cache.dart';

abstract class AppSecureCache {
  Future<void> set(String key, dynamic value);

  Future<T?> get<T>(String key);

  Future<bool> has(String key);

  Future<void> clear(String key);
}

@LazySingleton(as: AppSecureCache)
class AppCacheSecureImpl implements AppSecureCache {
  final AppCache _cache;
  final AppEncryptService _encryptService;

  AppCacheSecureImpl(this._cache, this._encryptService);

  @override
  Future<void> set(String key, dynamic value) async {
    final plain = jsonEncode(value);
    final encrypted = _encryptService.encrypt(plain);
    _cache.set(key, encrypted);
  }

  @override
  Future<T?> get<T>(String key) async {
    if (!_cache.has(key)) return null;

    final encrypted = _cache.get<String>(key);
    if (encrypted == null) return null;

    final decrypted = _encryptService.decrypt(encrypted);

    try {
      final decoded = jsonDecode(decrypted);
      return decoded as T;
    } catch (_) {
      return decrypted as T;
    }
  }

  @override
  Future<bool> has(String key) async {
    return _cache.has(key);
  }

  @override
  Future<void> clear(String key) async {
    _cache.clear(key);
  }
}
