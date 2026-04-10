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
                    text: controller.isLoggingIn.value ? "Opening Steam..." : "Login",
                    isDisabled: controller.isLoggingIn.value,
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
