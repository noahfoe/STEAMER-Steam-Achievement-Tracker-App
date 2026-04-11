// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:steam_achievement_tracker/features/login/controllers/login_controller.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';
import 'package:steam_achievement_tracker/services/widgets/button.dart';
import 'package:steam_achievement_tracker/services/widgets/my_app_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundColor,
      appBar: myAppBar(title: 'STEAMER'),
      body: GetBuilder<LoginController>(
        init: LoginController(),
        initState: (_) {},
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Track your Steam profile, library, and achievements in one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: KColors.inactiveTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => Button(
                    onTap: () => controller.login(context),
                    text: controller.isLoggingIn.value
                        ? "Opening Steam..."
                        : "Login",
                    isDisabled: controller.isLoggingIn.value,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isLoggingIn.value
                        ? null
                        : () => controller.loginWithTestMode(context),
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Closed Testing Mode'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KColors.activeTextColor,
                      side:
                          const BorderSide(color: KColors.lightBackgroundColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Closed Testing Mode skips Steam sign-in and loads a fully working sample profile for reviewers and testers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: KColors.inactiveTextColor,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
