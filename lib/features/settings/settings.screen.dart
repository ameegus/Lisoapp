import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';

import '../general/busy_indicator.widget.dart';
import 'settings_screen.controller.dart';

class SettingsScreen extends GetView<SettingsScreenController>
    with ConsoleMixin {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final address = masterWallet!.privateKey.address.hexEip55;

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const Divider(),
        ListTile(
          leading: Image.asset(
            Images.logo,
            height: 25,
          ),
          trailing: const Icon(LineIcons.copy),
          title: const Text('Liso Address'),
          subtitle: Text(address),
          onTap: () => Utils.copyToClipboard(address),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.lock, color: kAppColor),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('lock_vault'.tr),
          onTap: () => Get.offAndToNamed(Routes.unlock),
        ),
        // TODO: import vault from settings
        // const Divider(),
        // ListTile(
        //   leading: const Icon(LineIcons.download),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: Text('import_vault'.tr),
        //   onTap: () => Get.toNamed(Routes.import),
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.upload, color: kAppColor),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('export_vault'.tr),
          onTap: () => Get.toNamed(Routes.export),
          enabled: HiveManager.items!.isNotEmpty,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.syncIcon, color: kAppColor),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('reset_vault'.tr),
          onTap: () => Get.toNamed(Routes.reset),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.fileUpload, color: kAppColor),
          trailing: const Icon(LineIcons.angleRight),
          title: Text('export_wallet'.tr),
          onTap: controller.exportWallet,
        ),
        const Divider(),
        if (kDebugMode) ...[
          ListTile(
            title: const Text('Google Drive'),
            leading: const Icon(LineIcons.googleDrive, color: kAppColor),
            trailing: const Icon(LineIcons.angleRight),
            onTap: () => Get.offAndToNamed(Routes.signIn),
          ),
          const Divider(),
        ],
        // TODO: change vault password
        // ListTile(
        //   leading: const Icon(LineIcons.alternateShield),
        //   trailing: const Icon(LineIcons.angleRight),
        //   title: const Text('Change Password'),
        //   onTap: () => Get.toNamed(Routes.export),
        // ),
        // const Divider(),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: controller.obx(
        (_) => content,
        onLoading: Obx(
          () => BusyIndicator(
            message: controller.busyMessage.value,
          ),
        ),
      ),
    );
  }
}
