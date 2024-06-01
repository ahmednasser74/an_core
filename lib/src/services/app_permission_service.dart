import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../index.dart';

@LazySingleton()
class AppPermissionService {
  static final _appDeviceService = corePackageGetIt<AppDeviceService>();

  /// **Android:**
  /// - On Android 13 (API 33) and above, this permission is deprecated and
  /// always returns `PermissionStatus.denied`. Instead use `Permission.photos`,
  /// `Permission.video`, `Permission.audio` or
  /// `Permission.manageExternalStorage`. For more information see our
  /// [FAQ](https://pub.dev/packages/permission_handler#faq).
  /// - Below Android 13 (API 33), the `READ_EXTERNAL_STORAGE` and
  /// `WRITE_EXTERNAL_STORAGE` permissions are requested (depending on the
  /// definitions in the AndroidManifest.xml) file.
  /// **iOS:**
  /// - Access to folders like `Documents` or `Downloads`. Implicitly granted.
  static Future<bool> get isStoragePermissionGranted async {
    PermissionStatus storagePermission;
    if (_appDeviceService.isAndroidSdkLowerThan33 || Platform.isIOS) {
      storagePermission = await Permission.storage.request();
    } else {
      storagePermission = await Permission.manageExternalStorage.request();
    }

    if (storagePermission.isGranted) return true;
    return false;
  }

  static Future<bool> isPickImagePermissionGranted({bool? isForCamera}) async {
    //* If the permission is for camera, then check for camera permission
    if (isForCamera ?? false) {
      if (await isCameraPermissionGranted) return true;
      return false;
    }

    //* for handling gallery permission for android based on sdk version use storage permission
    //* otherwise use photos permission
    PermissionStatus permission;
    if (Platform.isAndroid && _appDeviceService.isAndroidSdkLowerThan33) {
      permission = await Permission.storage.request();
    } else {
      permission = await Permission.photos.request();
    }

    if (permission.isGranted) return true;
    return false;
  }

  static Future<bool> get isCameraPermissionGranted async {
    final permission = await Permission.camera.request();
    return permission.isGranted;
  }
}
