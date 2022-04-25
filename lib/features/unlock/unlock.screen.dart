import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/biometric.util.dart';
import '../general/remote_image.widget.dart';
import 'unlock_screen.controller.dart';

class UnlockScreen extends GetView<UnlockScreenController> with ConsoleMixin {
  const UnlockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RemoteImage(
          url: ConfigService.to.general.app.image,
          height: 100,
          placeholder: Image.asset(Images.logo, height: 100),
        ),
        const SizedBox(height: 20),
        Text(
          ConfigService.to.appName,
          style: const TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 15),
        Text(
          controller.passwordMode
              ? 'Enter your wallet password to proceed'
              : 'Enter the wallet password to unlock ${ConfigService.to.appName}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Obx(
          () => TextFormField(
            autofocus: true,
            controller: controller.passwordController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.visiblePassword,
            obscureText: controller.obscurePassword(),
            textInputAction: TextInputAction.go,
            onChanged: controller.onChanged,
            onFieldSubmitted: (text) => controller.unlock(),
            decoration: InputDecoration(
              hintText: 'password'.tr,
              suffixIcon: IconButton(
                padding: const EdgeInsets.only(right: 10),
                onPressed: controller.obscurePassword.toggle,
                icon: Icon(
                  controller.obscurePassword()
                      ? LineIcons.eye
                      : LineIcons.eyeSlash,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => TextButton.icon(
                label:
                    Text(controller.passwordMode ? 'proceed'.tr : 'unlock'.tr),
                icon: Icon(
                  controller.passwordMode
                      ? LineIcons.arrowCircleRight
                      : LineIcons.lockOpen,
                ),
                onPressed: controller.canProceed() ? controller.unlock : null,
              ),
            ),
            if (BiometricUtils.touchFaceIdSupported) ...[
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(LineIcons.fingerprint),
                onPressed: controller.authenticateBiometrics,
              ),
            ]
          ],
        ),
        if (!controller.passwordMode) ...[
          const SizedBox(height: 10),
          Obx(
            () => Text(
              '${controller.attemptsLeft()} ' + 'attempts_left'.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ]
      ],
    );

    return WillPopScope(
      onWillPop: () => Future.value(controller.passwordMode),
      child: Scaffold(
        appBar: controller.passwordMode ? AppBar() : null,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: controller.obx(
                (_) => content,
                onLoading: const BusyIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
