// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../cache/app_cache.dart' as _i184;
import '../cache/app_secure_cache.dart' as _i367;
import '../services/app_encrypt_service.dart' as _i382;
import '../services/app_permission_service.dart' as _i624;
import '../services/index.dart' as _i606;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  gh.lazySingleton<_i606.AppEncryptService>(
      () => registerModule.encryptionService);
  gh.lazySingleton<_i624.AppPermissionService>(
      () => _i624.AppPermissionService());
  gh.lazySingleton<_i184.AppCache>(
      () => _i184.AppCacheImpl(gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i367.AppSecureCache>(() => _i367.AppCacheSecureImpl(
        gh<_i184.AppCache>(),
        gh<_i382.AppEncryptService>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
