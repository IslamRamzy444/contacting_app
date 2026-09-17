// ignore_for_file: deprecated_member_use

import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:flutter/material.dart';

class RemoteVideoPlaceholder extends StatelessWidget {
  final String contactName;
  final String statusText;

  const RemoteVideoPlaceholder({
    super.key,
    required this.contactName,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Container(
      color: AppColors.blackColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: width * 0.18,
              backgroundColor: AppColors.primaryColor.withOpacity(0.15),
              child: Icon(
                Icons.person,
                size: width * 0.2,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: height * 0.02),
            Text(
              contactName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.whiteColor),
            ),
            SizedBox(height: height * 0.01),
            Text(
              statusText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.whiteColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
