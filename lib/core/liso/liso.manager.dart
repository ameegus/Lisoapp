import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/biometric.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../hive/hive.manager.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS

  // FUNCTIONS

  static Future<void> reset() async {
    console.info('resetting...');
    // clear filters
    DrawerMenuController.to.clearFilters();
    // delete biometric storage
    await BiometricUtils.delete(kBiometricPasswordKey);
    await BiometricUtils.delete(kBiometricSeedKey);
    // reset hive
    await HiveManager.reset();
    // nullify wallet
    WalletService.to.reset();
    await PersistenceService.to.box.erase();
    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    // reset s3 minio client
    S3Service.to.init();
    console.info('reset!');
  }
}
