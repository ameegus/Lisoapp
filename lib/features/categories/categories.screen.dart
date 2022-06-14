import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/general/remote_image.widget.dart';

import 'categories.service.dart';
import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'categories.controller.dart';
import 'categories_screen.controller.dart';

class CategoriesScreen extends StatelessWidget with ConsoleMixin {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesScreenController());
    final categoriesController = Get.find<CategoriesController>();

    Widget itemBuilder(context, index) {
      final category = categoriesController.data[index];

      void _confirmDelete() async {
        void _delete() async {
          // TODO: show the items binded to this group
          // TODO: if user proceeds, these items will also be deleted

          Get.back();
          await CategoriesService.to.box!.delete(category.key);
          Persistence.to.changes.val++;
          categoriesController.load();
        }

        final dialogContent = Text(
          'Are you sure you want to delete the category "${category.name}"?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Delete Category'),
          content: Utils.isDrawerExpandable
              ? dialogContent
              : SizedBox(width: 450, child: dialogContent),
          actions: [
            TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
            TextButton(onPressed: _delete, child: Text('confirm_delete'.tr)),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'delete'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _confirmDelete,
        ),
      ];

      return ListTile(
        enabled: !category.isReserved,
        title: Text(category.reservedName),
        subtitle: category.reservedDescription.isNotEmpty
            ? Text(category.reservedDescription)
            : null,
        leading: category.iconUrl.isEmpty
            ? const Icon(Iconsax.category)
            : RemoteImage(
                url: category.iconUrl,
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
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: categoriesController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = categoriesController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.category,
        message: 'no_custom_categories'.tr,
      ),
    );

    final appBar = AppBar(
      title: Text('custom_categories'.tr),
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
