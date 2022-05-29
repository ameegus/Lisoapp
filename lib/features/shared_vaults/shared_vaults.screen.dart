import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/hive/hive_shared_vaults.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/s3/model/s3_content.model.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../general/remote_image.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'shared_vault.controller.dart';
import 'shared_vaults_screen.controller.dart';

class SharedVaultsScreen extends GetView<SharedVaultsScreenController>
    with ConsoleMixin {
  const SharedVaultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedVaultsController = Get.find<SharedVaultsController>();

    Widget itemBuilder(context, index) {
      final vault = sharedVaultsController.data[index].data();

      void _confirmDelete() async {
        void _delete() async {
          Get.back();

          await FirestoreService.to.vaults.doc(vault.docId).delete();
          console.info('deleted in firestore');

          await S3Service.to.remove(S3Content(
              path: join(
            S3Service.to.sharedPath,
            '${vault.docId}.$kVaultExtension',
          )));

          console.info('deleted in s3');
        }

        final dialogContent = Text(
          'Are you sure you want to delete the shared vault: "${vault.name}"?',
        );

        Get.dialog(AlertDialog(
          title: Text('delete'.tr),
          content: Utils.isDrawerExpandable
              ? dialogContent
              : SizedBox(
                  width: 450,
                  child: dialogContent,
                ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: _delete,
              child: Text('confirm_delete'.tr),
            ),
          ],
        ));
      }

      void shareDialog() async {
        final results = HiveSharedVaultsService.to.data
            .where((e) => e.id == vault.docId)
            .toList();

        if (results.isEmpty) {
          return UIUtils.showSimpleDialog(
            'Cipher Key Not Found',
            'Please report to the developer.',
          );
        }

        final cipherKey = base64Encode(results.first.cipherKey);
        final obscureText = true.obs;

        final passwordDecoration = InputDecoration(
          labelText: 'Cipher Key',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: obscureText.toggle,
                icon: Obx(
                  () => Icon(
                    obscureText.value ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Utils.copyToClipboard(cipherKey),
                icon: const Icon(Iconsax.copy),
              )
            ],
          ),
        );

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: vault.docId,
              decoration: InputDecoration(
                labelText: 'Shared Vault ID',
                suffixIcon: IconButton(
                  onPressed: () => Utils.copyToClipboard(vault.docId),
                  icon: const Icon(Iconsax.copy),
                ),
              ),
            ),
            const Divider(),
            Obx(
              () => TextFormField(
                initialValue: cipherKey,
                obscureText: obscureText.value,
                decoration: passwordDecoration,
              ),
            ),
          ],
        );

        void _send() {
          Get.back();

          UIUtils.showSimpleDialog(
            'E2EE Messenger',
            "A built-in end to end encryption messenger is coming for ${ConfigService.to.appName} where you can safely send & receive private information",
          );
        }

        Get.dialog(AlertDialog(
          title: const Text('Vault Credentials'),
          content: Utils.isDrawerExpandable
              ? content
              : SizedBox(width: 450, child: content),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: _send,
              child: const Text('Send'),
            ),
          ],
        ));
      }

      final menuItems = [
        if (Persistence.to.canShare) ...[
          ContextMenuItem(
            title: 'share'.tr,
            leading: const Icon(Iconsax.share),
            onSelected: shareDialog,
          ),
        ],
        ContextMenuItem(
          title: 'delete'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _confirmDelete,
        ),
      ];

      return ListTile(
        title: Text(vault.name),
        subtitle: vault.description.isNotEmpty ? Text(vault.description) : null,
        leading: vault.iconUrl.isEmpty
            ? const Icon(Iconsax.briefcase)
            : RemoteImage(
                url: vault.iconUrl,
                width: 35,
                alignment: Alignment.centerLeft,
              ),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      );
    }

    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: sharedVaultsController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );

    final content = sharedVaultsController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.briefcase,
        message: 'no_shared_vaults'.tr,
      ),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
        message: message!,
        child: TextButton(
          onPressed: sharedVaultsController.restart,
          child: Text('try_again'.tr),
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('shared_vaults'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.create,
      child: const Icon(LineIcons.plus),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
