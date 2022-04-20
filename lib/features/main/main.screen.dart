import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/item/item.tile.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/resources/resources.dart';

import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import 'main_screen.controller.dart';

// ignore: use_key_in_widget_constructors
class MainScreen extends GetResponsiveView<MainScreenController>
    with ConsoleMixin {
  MainScreen({Key? key})
      : super(
          key: key,
          settings: const ResponsiveScreenSettings(
            desktopChangePoint: kDesktopChangePoint,
          ),
        );

  Widget itemBuilder(context, index) => ItemTile(
        controller.data[index],
        key: GlobalKey(),
      );

  @override
  Widget? builder() {
    final listView = Obx(
      () => Opacity(
        opacity: controller.syncing ? 0.5 : 1,
        child: AbsorbPointer(
          absorbing: controller.syncing,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: controller.data.length,
            itemBuilder: itemBuilder,
            separatorBuilder: (context, index) => const Divider(height: 0),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'no_items'.tr,
        child: DrawerMenuController.to.boxFilter.value == HiveBoxFilter.all
            ? Obx(
                () => ContextMenuButton(
                  controller.menuItemsCategory,
                  enabled: !controller.syncing,
                  child: TextButton.icon(
                    icon: const Icon(LineIcons.plus),
                    label: Text(
                      'add_item'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: !controller.syncing ? () {} : null,
                  ),
                ),
              )
            : null,
      ),
    );

    final appBar = AppBar(
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, height: 17),
          const SizedBox(width: 10),
          const Text(kAppName, style: TextStyle(fontSize: 20))
        ],
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: const Icon(LineIcons.search),
            onPressed: !controller.syncing ? controller.search : null,
          ),
        ),
        Obx(
          () => ContextMenuButton(
            controller.menuItemsSort,
            enabled: !controller.syncing,
            initialItem: controller.menuItemsSort.firstWhere(
              (e) => controller.sortOrder.value.name
                  .toLowerCase()
                  .contains(e.title.toLowerCase().replaceAll(' ', '')),
            ),
            child: IconButton(
              icon: const Icon(LineIcons.sort),
              onPressed: !controller.syncing ? () {} : null,
            ),
          ),
        ),
        SimpleBuilder(
          builder: (_) {
            if (!PersistenceService.to.sync.val) return const SizedBox.shrink();

            final changeCount = PersistenceService.to.changes.val;

            final syncButton = IconButton(
              icon: const Icon(LineIcons.syncIcon),
              onPressed: controller.sync,
            );

            final syncBadge = Badge(
              badgeContent: Text(changeCount.toString()),
              position: BadgePosition.topEnd(top: -1, end: -5),
              child: syncButton,
            );

            const progressIndicator = Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
              ),
            );

            return Obx(
              () => Visibility(
                visible: !controller.syncing,
                child: changeCount > 0 ? syncBadge : syncButton,
                replacement:
                    controller.syncing ? progressIndicator : const SizedBox(),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
      ],
    );

    final floatingActionButton = Obx(
      () => ContextMenuButton(
        controller.menuItemsCategory,
        enabled: !controller.syncing,
        child: FloatingActionButton(
          child: const Icon(LineIcons.plus),
          onPressed: () {},
        ),
      ),
    );

    if (screen.isDesktop) {
      return Row(
        children: [
          const SizedBox(width: 240.0, child: DrawerMenu()),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              key: controller.scaffoldKey,
              appBar: appBar,
              body: content,
              floatingActionButton: Obx(
                () =>
                    DrawerMenuController.to.boxFilter.value == HiveBoxFilter.all
                        ? floatingActionButton
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      );
    }
    // 1 SECTION FOR PHONE DEVICES
    else {
      return Scaffold(
        key: controller.scaffoldKey,
        appBar: appBar,
        body: content,
        floatingActionButton: floatingActionButton,
        drawer: const DrawerMenu(),
      );
    }
  }
}
