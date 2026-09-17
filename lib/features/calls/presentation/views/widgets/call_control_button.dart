import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:flutter/material.dart';

class CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: width * 0.16,
            height: width * 0.16,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: backgroundColor ?? AppColors.greyColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.whiteColor, size: width * 0.07),
          ),
        ),
        SizedBox(height: height * 0.01),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.whiteColor),
        ),
      ],
    );
  }
}
