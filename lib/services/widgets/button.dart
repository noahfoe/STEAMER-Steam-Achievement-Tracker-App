import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

/// Creates a custom button.
class Button extends StatelessWidget {
  /// Text to display in the button.
  final String text;

  /// Whether the button is disabled/Inactive.
  ///
  /// Shows dark background color if true.
  final bool isDisabled;

  /// Padding inside the button (around `text`).
  final EdgeInsetsGeometry? padding;

  /// Function to call when the button is tapped.
  final Function() onTap;

  const Button({
    Key? key,
    required this.text,
    required this.onTap,
    this.padding,
    this.isDisabled = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 40,
              ),
          decoration: BoxDecoration(
            color: isDisabled ? KColors.darkButtonColor : KColors.buttonColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: KColors.activeTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
