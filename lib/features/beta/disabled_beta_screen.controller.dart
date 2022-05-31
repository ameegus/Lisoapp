import 'package:get/get.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DisabledBetaScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DisabledBetaScreenController(), fenix: true);
  }
}

class DisabledBetaScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo()?.version}+${packageInfo()?.buildNumber}';

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }

  // FUNCTIONS
}
