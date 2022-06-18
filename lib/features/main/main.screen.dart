import 'package:badges/badges.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/items/item.tile.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../../core/utils/utils.dart';
import '../connectivity/connectivity_bar.widget.dart';
import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../general/custom_chip.widget.dart';
import '../general/remote_image.widget.dart';
import '../s3/s3.service.dart';
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

  @override
  Widget? builder() {
    final itemsController = Get.find<ItemsController>();
    final drawerController = Get.find<DrawerMenuController>();

    final addItemButton = ContextMenuButton(
      controller.menuItemsCategory,
      child: TextButton.icon(
        icon: const Icon(Iconsax.add_circle),
        onPressed: () {},
        label: Text(
          'add_item'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: itemsController.data.length,
        itemBuilder: (_, index) => ItemTile(itemsController.data[index]),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
      ),
    );

    var childContent = itemsController.obx(
      (_) => listView,
      // onLoading: const BusyIndicator(),
      onEmpty: Obx(
        () => CenteredPlaceholder(
          iconData: Iconsax.document,
          message: 'no_items'.tr,
          child: drawerController.filterTrashed.value ? null : addItemButton,
        ),
      ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      childContent = RefreshIndicator(
        onRefresh: S3Service.to.sync,
        child: childContent,
      );
    }

    // filters indicator in the bottom
    final filters = Wrap(
      runSpacing: 3,
      spacing: 3,
      children: [
        const Text(
          'Filters: ',
          style: TextStyle(fontSize: 9, color: Colors.grey),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.briefcase, size: 10),
            label: Text(
              drawerController.filterGroupLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.share, size: 10),
            label: Text(
              drawerController.filterSharedVaultLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.filter, size: 10),
            label: Text(
              drawerController.filterToggleLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.category, size: 10),
            label: Text(
              drawerController.filterCategoryLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.tag, size: 10),
            label: Text(
              drawerController.filterTagLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );

    final content = Column(
      children: [
        Obx(
          () => Visibility(
            visible: S3Service.to.syncing.value,
            child: const LinearProgressIndicator(),
          ),
        ),
        const ConnectivityBar(),
        PersistenceBuilder(
          builder: (p, context) => Visibility(
            visible: !p.backedUpSeed.val,
            child: Card(
              elevation: 1.0,
              child: ListTile(
                selected: true,
                dense: Utils.isDrawerExpandable,
                selectedTileColor: themeColor.withOpacity(0.05),
                // TODO: localize
                title: const Text("Backup Your Seed Phrase"),
                subtitle: const Text(
                  "Please confirm you've backed up your seed phrase",
                ),
                leading: const Icon(Iconsax.key),
                trailing: OutlinedButton(
                  onPressed: controller.showSeed,
                  child: const Text('Backup'),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: childContent),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: filters,
          ),
        ),
      ],
    );

    final appBarActions = [
      IconButton(
        icon: const Icon(Iconsax.search_normal),
        onPressed: controller.search,
      ),
      Obx(
        () => ContextMenuButton(
          controller.menuItemsSort,
          initialItem: controller.menuItemsSort.firstWhere(
            (e) => ItemsController.to.sortOrder.value.name
                .toLowerCase()
                .contains(e.title.toLowerCase().replaceAll(' ', '')),
          ),
          child: const Icon(Iconsax.sort),
        ),
      ),
      PersistenceBuilder(
        builder: (p, context) => Badge(
          showBadge: p.sync.val && p.changes.val > 0,
          badgeContent: Text(p.changes.val.toString()),
          position: BadgePosition.topEnd(top: -1, end: -5),
          child: ContextMenuButton(
            controller.menuItems,
            child: const Icon(LineIcons.verticalEllipsis),
          ),
        ),
      ),
      const SizedBox(width: 10),
    ];

    final appBarTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RemoteImage(
          url: ConfigService.to.general.app.image,
          height: 20,
          placeholder: Image.asset(Images.logo, height: 20),
        ),
        const SizedBox(width: 10),
        Text(
          ConfigService.to.appName,
          style: const TextStyle(fontSize: 20),
        ),
        if (isBeta) ...[
          const SizedBox(width: 3),
          const Text(
            'Beta',
            style: TextStyle(fontSize: 12, color: Colors.cyan),
          ),
        ]
      ],
    );

    final appBar = AppBar(
      centerTitle: false,
      title: appBarTitle,
      actions: appBarActions,
    );

    // TODO: show only if there are trash items
    final clearTrashFab = FloatingActionButton(
      onPressed: controller.emptyTrash,
      child: const Icon(Iconsax.trash),
    );

    final fab = Obx(
      () {
        if (drawerController.filterTrashed.value) {
          if (drawerController.trashedCount > 0) {
            return clearTrashFab;
          } else {
            return const SizedBox.shrink();
          }
        }

        return ContextMenuButton(
          controller.menuItemsCategory,
          child: FloatingActionButton(
            child: const Icon(LineIcons.plus),
            onPressed: () {},
          ),
        );
      },
    );

    if (screen.isDesktop) {
      return Row(
        children: [
          const SizedBox(width: 280.0, child: DrawerMenu()),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              appBar: appBar,
              body: content,
              floatingActionButton: fab,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(child: content),
        drawer: const DrawerMenu(),
        floatingActionButton: fab,
      );
    }
  }
}
