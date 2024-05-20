import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@LazySingleton()
class AppDeviceService {
  late AndroidDeviceInfo _androidInfo;
  late IosDeviceInfo _iosInfo;
  late PackageInfo _appInfo;
  AppDeviceService() {
    init();
  }

  Future<void> init() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _androidInfo = await deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      _iosInfo = await deviceInfoPlugin.iosInfo;
    }
    _appInfo = await PackageInfo.fromPlatform();
  }

  ({String name, String version, String deviceType, String deviceModel, String deviceIdentifier}) get deviceInfo {
    String name, version, deviceType, deviceModel, deviceIdentifier;

    if (Platform.isAndroid) {
      name = _androidInfo.model;
      version = _androidInfo.version.release;
      deviceType = 'Android';
      deviceModel = _androidInfo.model;
      deviceIdentifier = _androidInfo.id;
      return (name: name, version: version, deviceType: deviceType, deviceModel: deviceModel, deviceIdentifier: deviceIdentifier);
    } else if (Platform.isIOS) {
      name = _iosInfo.name;
      version = _iosInfo.systemVersion;
      deviceType = 'iOS';
      deviceModel = _iosInfo.model;
      deviceIdentifier = _iosInfo.identifierForVendor ?? '';
      return (name: name, version: version, deviceType: deviceType, deviceModel: deviceModel, deviceIdentifier: deviceIdentifier);
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  bool get isAndroidSdkLowerThan33 {
    return _androidInfo.version.sdkInt < 33;
  }

  //* get package or bundle [com.example.app]
  String get packageName {
    return _appInfo.packageName;
  }

  //* get app version [1.0.0]
  String get appVersion {
    return _appInfo.version;
  }

  //* get app name [App Name]
  String get appName {
    return _appInfo.appName;
  }
}
