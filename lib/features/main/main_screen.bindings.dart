import 'package:get/get.dart';

import '../../core/form_fields/password.field.dart';
import '../../core/form_fields/pin.field.dart';
import '../about/about_screen.controller.dart';
import '../drawer/drawer_widget.controller.dart';
import '../export/export_screen.controller.dart';
import '../ipfs/explorer/ipfs_exporer_screen.controller.dart';
import '../ipfs/ipfs_screen.controller.dart';
import '../item/item_screen.controller.dart';
import '../reset/reset_screen.controller.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../settings/settings_screen.controller.dart';
import 'main_screen.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController(), fenix: true);
    Get.lazyPut(() => DrawerMenuController(), fenix: true);
    // WIDGETS
    Get.create(() => PasswordFormFieldController());
    Get.create(() => PINFormFieldController());
    // SCREENS
    Get.create(() => ItemScreenController());
    Get.create(() => SettingsScreenController());
    Get.create(() => AboutScreenController());
    Get.create(() => ExportScreenController());
    Get.create(() => ResetScreenController());
    // ipfs
    Get.create(() => IPFSScreenController());
    Get.create(() => IPFSExplorerScreenController());
    // S3
    Get.create(() => S3ExplorerScreenController());
  }
}
