import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/hive_groups.service.dart';

import '../../../core/utils/globals.dart';
import '../../core/hive/hive_items.service.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../main/main_screen.controller.dart';

enum HiveBoxFilter {
  all,
  archived,
  trash,
}

class DrawerMenuController extends GetxController with ConsoleMixin {
  // CONSTRUCTOR
  static DrawerMenuController get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();

  // maintain expansion tile state
  bool networksExpanded = false,
      groupsExpanded = false,
      sharedVaultsExpanded = false,
      tagsExpanded = false,
      categoriesExpanded = false,
      toolsExpanded = false;

  // PROPERTIES
  final filterGroupId = 'personal'.obs;
  final filterFavorites = false.obs;
  final filterProtected = false.obs;
  final filterTrashed = false.obs;
  final filterDeleted = false.obs;
  final filterCategory = LisoItemCategory.none.obs;
  final filterTag = ''.obs;

  // GETTERS

  Iterable<HiveLisoItem> get groupedItems => HiveItemsService.to.data.where(
        (e) => e.groupId == filterGroupId.value,
      );

  // Obtain used categories distinctly
  Set<String> get categories {
    final Set<String> categories = {};

    for (var e in groupedItems) {
      categories.add(e.category);
    }

    return categories;
  }

  // Obtain used tags distinctly
  Set<String> get tags {
    final usedTags = groupedItems
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> tags = {};

    if (usedTags.isNotEmpty) {
      tags.addAll(usedTags.reduce((a, b) => a + b).toSet());
    }

    return tags;
  }

  int get itemsCount =>
      groupedItems.where((e) => !e.trashed && !e.deleted).length;

  int get favoriteCount =>
      groupedItems.where((e) => e.favorite && !e.trashed && !e.deleted).length;

  int get protectedCount =>
      groupedItems.where((e) => e.protected && !e.trashed && !e.deleted).length;

  int get trashedCount =>
      groupedItems.where((e) => e.trashed && !e.deleted).length;

  int get deletedCount => groupedItems.where((e) => e.deleted).length;

  bool get filterAll =>
      !filterFavorites.value &&
      !filterProtected.value &&
      !filterTrashed.value &&
      !filterDeleted.value;

  List<Widget> get groupTiles => HiveGroupsService.to.data
      .map((e) => ListTile(
            title: Text(e.reservedName),
            leading: const Icon(Iconsax.briefcase),
            selected: e.id == filterGroupId.value,
            onTap: () {
              filterGroupId.value = e.id;
              done();
            },
          ))
      .toList();

  String get filterGroupLabel {
    final groups =
        HiveGroupsService.to.data.where((e) => e.id == filterGroupId.value);
    if (groups.isEmpty) return 'Error';
    return groups.first.reservedName;
  }

  String get filterToggleLabel {
    if (filterAll) return 'All';
    if (filterFavorites.value) return 'Favorites';
    if (filterProtected.value) return 'Protected';
    if (filterTrashed.value) return 'Trashed';
    if (filterDeleted.value) return 'Deleted';
    return 'Unknown';
  }

  String get filterTagLabel => filterTag.value;

  String get filterCategoryLabel =>
      filterCategory.value != LisoItemCategory.none
          ? GetUtils.capitalizeFirst(filterCategory.value.name)!
          : '';

  // INIT

  // FUNCTIONS

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterProtectedItems() async {
    filterProtected.toggle();
    filterFavorites.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterTrashedItems() async {
    filterTrashed.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterDeletedItems() async {
    filterDeleted.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    done();
  }

  void filterAllItems() {
    clearFilters();
    done();
  }

  void filterByCategory(String category) {
    final categoryEnum = LisoItemCategory.values.byName(category);
    // if already selected, deselect
    filterCategory.value = categoryEnum == filterCategory.value
        ? LisoItemCategory.none
        : categoryEnum;
    done();
  }

  void filterByTag(String tag) {
    // if already selected, deselect
    if (tag == filterTag.value) tag = '';
    filterTag.value = tag;
    done();
  }

  void clearFilters() {
    filterCategory.value = LisoItemCategory.none;
    filterTag.value = '';
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
  }

  void files() async {
    Utils.adaptiveRouteOpen(
      name: Routes.s3Explorer,
      parameters: {'type': 'explorer'},
    );
  }

  void done() async {
    MainScreenController.to.load();
    if (Utils.isDrawerExpandable) Get.back();
  }
}
