import 'package:flutter/material.dart';
import 'package:steam_achievement_tracker/services/utils/colors.dart';

class NetworkIconImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderRadius;

  const NetworkIconImage({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return const _IconPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const _IconPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return const _IconPlaceholder(
              icon: Icons.broken_image_outlined,
            );
          },
        ),
      ),
    );
  }
}

class _IconPlaceholder extends StatelessWidget {
  final IconData icon;

  const _IconPlaceholder({
    this.icon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColors.primaryColor,
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: KColors.inactiveTextColor,
        size: 22,
      ),
    );
  }
}
