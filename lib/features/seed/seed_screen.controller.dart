import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/metadata.hive.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/selector.sheet.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/features/passphrase_card/passphrase.card.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

const originItems = [
  'Metamask',
  'TrustWallet',
  'Exodus',
  'MyEtherWallet',
  'BitGo',
  'Math Wallet'
];

const ledgerItems = [
  'Blockchain',
  'Hashgraph',
  'Directed Acyclic Graph',
  'Holochain',
  'Tempo',
];

class SeedScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SeedScreenController());
  }
}

class SeedScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  HiveSeed? object;

  final formKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'] as String;

  PassphraseCard? passphraseCard;
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  final originDropdownItems = originItems
      .map(
        (e) => DropdownMenuItem(child: Text(e), value: e),
      )
      .toList();

  final ledgerDropdownItems = ledgerItems
      .map(
        (e) => DropdownMenuItem(child: Text(e), value: e),
      )
      .toList();

  // PROPERTIES
  final selectedOrigin = originItems.first.obs;
  final selectedLedger = ledgerItems.first.obs;

  // GETTERS

  // INIT

  @override
  void onInit() {
    if (mode == 'add') {
      passphraseCard = const PassphraseCard(mode: PassphraseMode.none);
    } else if (mode == 'update') {
      final index = int.parse(Get.parameters['index'].toString());
      object = HiveManager.seeds!.getAt(index);

      passphraseCard = PassphraseCard(
        mode: PassphraseMode.none,
        phrase: object!.mnemonic,
      );

      addressController.text = object!.address;
      descriptionController.text = object!.description;
      selectedOrigin.value = object!.origin;
      selectedLedger.value = object!.ledger;
    }

    super.onInit();
  }

  // FUNCTIONS

  void showSeedOptions() {
    SelectorSheet(
      title: 'Seed Options',
      items: [
        SelectorItem(
          title: 'Generate 12 words',
          leading: const Icon(LineIcons.syncIcon),
          onSelected: () =>
              passphraseCard!.controller.generateSeed(strength: 128),
        ),
        SelectorItem(
          title: 'Generate 24 words',
          leading: const Icon(LineIcons.syncIcon),
          onSelected: () =>
              passphraseCard!.controller.generateSeed(strength: 256),
        ),
      ],
    ).show();
  }

  void add() async {
    if (!formKey.currentState!.validate()) {
      UIUtils.showSnackBar(
        title: 'Invalid mnemonic phrase',
        message: 'Please check your mnemonic seed phrase',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    final newSeed = HiveSeed(
      mnemonic: passphraseCard!.obtainMnemonicPhrase()!,
      address: addressController.text,
      description: descriptionController.text,
      ledger: selectedLedger.value,
      origin: selectedOrigin.value,
      metadata: await HiveMetadata.get(),
    );

    final exists = HiveManager.seeds!.values
        .where((e) =>
            e.address == newSeed.address || e.mnemonic == newSeed.mnemonic)
        .isNotEmpty;

    if (exists) {
      UIUtils.showSnackBar(
        title: 'Already exists',
        message: 'Either the address or mnemonic phrase already exists',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    await HiveManager.seeds!.add(newSeed);
    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (object == null) return;

    object!.mnemonic = passphraseCard!.obtainMnemonicPhrase()!;
    object!.address = addressController.text;
    object!.description = descriptionController.text;
    object!.origin = selectedOrigin.value;
    object!.ledger = selectedLedger.value;
    object!.metadata = await object!.metadata.getUpdated();
    await object?.save();

    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void delete() async {
    await object?.delete();
    MainScreenController.to.load();
    Get.back();

    console.info('success');
  }

  void changedOriginItem(String? item) {
    selectedOrigin.value = item!;
  }

  void changedLedgerItem(String? item) {
    selectedLedger.value = item!;
  }
}
