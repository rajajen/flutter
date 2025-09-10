import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgIconButton extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback onPressed;
  final String? tooltip;

  const CustomSvgIconButton({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.iconColor,
    this.backgroundColor,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      color: iconColor,
    );

    if (backgroundColor != null) {
      iconWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: iconWidget,
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: tooltip != null
          ? Tooltip(message: tooltip!, child: iconWidget)
          : iconWidget,
    );
  }
}
