import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

class AppRoute {
  static Route<T> fadeSlide<T>({
    required WidgetBuilder builder,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      opaque: true,
      maintainState: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          color: KColors.backgroundColor,
          child: builder(context),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        );
        final slide = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(fade),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(slide),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(fade),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
