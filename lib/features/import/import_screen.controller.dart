import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../s3/s3.service.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
  }
}

enum ImportMode {
  file,
  liso,
  s3,
}

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final seedController = TextEditingController();
  final filePathController = TextEditingController();

  final ipfsUrlController = TextEditingController(
    text: PersistenceService.to.ipfsServerUrl,
  );

  // PROPERTIES
  final importMode = ImportMode.liso.obs;
  final ipfsBusy = false.obs;

  // GETTERS
  String get archiveFilePath => importMode() == ImportMode.file
      ? filePathController.text
      : LisoManager.tempVaultFilePath;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Future<bool> _downloadVault() async {
    final privateKey =
        WalletService.to.mnemonicToPrivateKey(seedController.text);
    final address = privateKey.address.hex;
    final fileName = '$address.$kVaultExtension';

    final downloadResult = await S3Service.to.downloadVault(
      path: join(address, fileName),
    );

    dynamic _error;
    downloadResult.fold(
      (error) => _error = error,
      (file) {},
    );

    if (_error != null) {
      console.error('download error: $_error');

      final newUser =
          _error is MinioError && _error.message!.contains('does not exist');

      if (newUser) {
        UIUtils.showSimpleDialog(
          'No vault found',
          "It looks like you're a new $kAppName user. Consider creating a vault instead and start securing your data.",
        );
      } else {
        UIUtils.showSimpleDialog(
          'Error Downloading',
          '$_error > _downloadVault()',
        );
      }

      return false;
    }

    return true;
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;
    change(null, status: RxStatus.loading());

    // download and save vault file from IPFS
    if (importMode.value == ImportMode.liso) {
      final success = await _downloadVault();
      if (!success) {
        FileUtils.delete(archiveFilePath); // delete temp downloaded vault
        return change(null, status: RxStatus.success());
      }
    }

    // read archive
    final result = LisoManager.readArchive(archiveFilePath);
    FileUtils.delete(archiveFilePath); // delete temp downloaded vault
    Archive? archive;
    dynamic _error;

    result.fold(
      (error) => _error = error,
      (response) => archive = response,
    );

    console.info('archive files: ${archive?.files.length}');

    if (_error != null || (archive != null && archive!.files.isEmpty)) {
      UIUtils.showSimpleDialog(
        'Error Extracting',
        '$_error > continuePressed()',
      );

      return change(null, status: RxStatus.success());
    }

    // get items.hive file
    final itemsHiveFile = archive!.files.firstWhere(
      (e) => e.isFile && e.name.contains('items.hive'),
    );

    // temporarily extract for verification
    await LisoManager.extractArchiveFile(
      itemsHiveFile,
      path: LisoManager.tempPath,
    );
    // check if encryption key is correct
    final credentials =
        WalletService.to.mnemonicToPrivateKey(seedController.text);

    final isCorrect = await HiveManager.isEncryptionKeyCorrect(
      credentials.privateKey,
    );

    if (!isCorrect) {
      UIUtils.showSimpleDialog(
        'Incorrect Seed Phrase',
        'Please enter the mnemonic seed phrase you backed up to secure your vault.',
      );

      return change(null, status: RxStatus.success());
    }

    // extract all hive boxes
    await LisoManager.extractArchive(
      archive!,
      path: LisoManager.hivePath,
    );
    // turn on sync setting if successfully imported via cloud
    if (importMode.value == ImportMode.liso) {
      PersistenceService.to.sync.val = true;
    }

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Imported Vault',
      body: basename(archiveFilePath),
    );

    Get.toNamed(
      Routes.createPassword,
      parameters: {'privateKeyHex': HEX.encode(credentials.privateKey)},
    );
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      console.warning("canceled file picker");
      return;
    }

    filePathController.text = result.files.single.path!;
  }
}
