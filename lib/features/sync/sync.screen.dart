import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';

import '../../core/services/persistence.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';

class SyncScreen extends StatelessWidget with ConsoleMixin {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    console.info('PREVIOUS ROUTE: ${Get.previousRoute}');

    final newSetup = Get.parameters['new_setup'] != null;

    void save() {
      final persistence = Get.find<PersistenceService>();
      persistence.syncConfirmed.val = true;

      if (newSetup) {
        Get.offNamedUntil(Routes.main, (route) => false);
      } else {
        Get.back();
      }
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.memory, size: 100, color: kAppColor),
        const SizedBox(height: 20),
        const Text(
          'Vault Management',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Choose your preferred vault management feature",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        SimpleBuilder(
          builder: (context) {
            return Column(
              children: <Widget>[
                RadioListTile<bool>(
                  title: const Text('$kAppName Cloud Sync'),
                  subtitle: const Text(
                    'Securely keep multiple devices in sync',
                  ),
                  secondary: const Icon(LineIcons.cloud),
                  value: true,
                  groupValue: PersistenceService.to.sync.val,
                  onChanged: (value) => PersistenceService.to.sync.val = value!,
                ),
                RadioListTile<bool>(
                  title: const Text('Offline'),
                  subtitle: const Text(
                    'Manually import/export offline vaults across your devices',
                  ),
                  secondary: const Icon(Icons.wifi_off),
                  value: false,
                  groupValue: PersistenceService.to.sync.val,
                  onChanged: (value) => PersistenceService.to.sync.val = value!,
                ),
              ],
            );
          },
        ),
        if (newSetup) ...[
          const Divider(),
          TextButton.icon(
            onPressed: save,
            label: Text('continue'.tr),
            icon: const Icon(LineIcons.arrowCircleRight),
          ),
        ] else ...[
          const Divider(),
          ListTile(
            title: Text('time_machine_explorer'.tr),
            subtitle: const Text('Go back in time to undo your changes'),
            leading: const Icon(LineIcons.clock),
            trailing: const Icon(LineIcons.angleRight),
            onTap: () => Utils.adaptiveRouteOpen(name: Routes.s3Explorer),
          ),
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(!newSetup),
      child: Scaffold(
        appBar: newSetup
            ? null
            : AppBar(
                centerTitle: false,
                leading: const AppBarLeadingButton(),
              ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: Styles.containerConstraints,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
