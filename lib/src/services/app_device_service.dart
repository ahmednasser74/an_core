import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDeviceService {
  static Future<bool> get isAndroidSdkLowerThan33 async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt < 33;
  }

  static Future<({String name, String version, String deviceType, String deviceModel})> get deviceInfo async {
    String name, version, deviceType, deviceModel;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      name = androidInfo.model;
      version = androidInfo.version.release;
      deviceType = 'Android';
      deviceModel = androidInfo.model;
      return (name: name, version: version, deviceType: deviceType, deviceModel: deviceModel);
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      name = iosInfo.name;
      version = iosInfo.systemVersion;
      deviceType = 'iOS';
      deviceModel = iosInfo.model;
      return (name: name, version: version, deviceType: deviceType, deviceModel: deviceModel);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static Future<PackageInfo> get _appInfo async => await PackageInfo.fromPlatform();

  //* get package or bundle [com.example.app]
  static Future<String> get packageName async {
    final app = await _appInfo;
    return app.packageName;
  }

  //* get app version [1.0.0]
  static Future<String> get appVersion async {
    final app = await _appInfo;
    return app.version;
  }

  //* get app name [App Name]
  static Future<String> get appName async {
    final app = await _appInfo;
    return app.appName;
  }
}
