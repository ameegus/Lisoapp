import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';
import 'package:liso/features/categories/categories.service.dart';
import 'package:liso/core/liso/vault.model.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/files/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../features/groups/groups.service.dart';
import '../../features/items/items.service.dart';
import '../hive/models/metadata/metadata.hive.dart';
import '../services/cipher.service.dart';
import '../utils/globals.dart';
import 'liso_paths.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS

  // FUNCTIONS

  static Future<void> reset() async {
    console.info('resetting...');
    // clear filters
    DrawerMenuController.to.filterGroupId.value = 'personal';
    DrawerMenuController.to.clearFilters();
    // reset persistence
    await Persistence.reset();
    // reset s3 minio client
    S3Service.to.init();
    // reset wallet
    WalletService.to.reset();
    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }
    // reset firebase
    await AuthService.to.signOut();
    // clear hives
    await HiveService.to.clear();
    // clean temp folder
    await LisoPaths.cleanTemp();
    // reset variables
    S3Service.to.backedUp = false;
    // invalidate purchases
    await Purchases.invalidateCustomerInfoCache();
    // sign out
    AuthenticationMiddleware.signedIn = false;
    console.info('reset!');
  }

  static Future<String> compactJson() async {
    final persistenceMap = Persistence.box!.toMap();
    // exclude sensitive data
    persistenceMap.remove('wallet-password');
    persistenceMap.remove('wallet-signature');
    persistenceMap.remove('wallet-private-key-hex');

    final vault = LisoVault(
      groups: GroupsService.to.data,
      categories: CategoriesService.to.data,
      items: ItemsService.to.data,
      persistence: persistenceMap,
      version: kVaultFormatVersion,
      metadata: await HiveMetadata.get(),
    );

    return vault.toJsonString();
  }

  static Future<void> importVault(LisoVault vault,
      {Uint8List? cipherKey}) async {
    await GroupsService.to.import(vault.groups, cipherKey: cipherKey);
    await CategoriesService.to.import(vault.categories!, cipherKey: cipherKey);
    await ItemsService.to.import(vault.items, cipherKey: cipherKey);
  }

  static Future<LisoVault> parseVaultFile(
    File file, {
    Uint8List? cipherKey,
  }) async {
    final decryptedFile = await CipherService.to.decryptFile(
      file,
      cipherKey: cipherKey,
    );

    final jsonString = await decryptedFile.readAsString();
    final jsonMap = jsonDecode(jsonString); // TODO: isolate
    return LisoVault.fromJson(jsonMap);
  }

  static Future<void> createBackup() async {
    // make a temporary local backup
    final encryptedBytes = CipherService.to.encrypt(
      utf8.encode(await compactJson()),
    );

    final backupFile = File(join(
      LisoPaths.tempPath,
      'backup.$kVaultExtension',
    ));

    final encryptedBackupFile = await backupFile.writeAsBytes(encryptedBytes);
    console.info('backup created: ${encryptedBackupFile.path}');
  }
}
