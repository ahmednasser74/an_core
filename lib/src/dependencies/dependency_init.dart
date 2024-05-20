import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../an_core.dart';
import 'dependency_init.config.dart';

final GetIt corePackageGetIt = GetIt.instance;

@InjectableInit(
  usesNullSafety: true,
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<GetIt> cacheCorePackageConfigDependencies() async {
  // final instance = AppDeviceService();
  // await instance.init();
  return $initGetIt(corePackageGetIt);
}
