import 'package:contacting_app/core/resources/app_colors.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static void Function({
    required BuildContext context,
    required String loadingText,
  })?
  _showLoadingOverride;
  static void Function({required BuildContext context})? _removeLoadingOverride;
  static void Function({
    required BuildContext context,
    String? title,
    required String message,
    String? posActionName,
    Function? posAction,
    String? negActionName,
    Function? negAction,
  })?
  _showMessageOverride;
  static void setShowLoadingOverride(
    void Function({required BuildContext context, required String loadingText})
    fn,
  ) {
    _showLoadingOverride = fn;
  }

  static void setRemoveLoadingOverride(
    void Function({required BuildContext context}) fn,
  ) {
    _removeLoadingOverride = fn;
  }

  static void setShowMessageOverride(
    void Function({
      required BuildContext context,
      String? title,
      required String message,
      String? posActionName,
      Function? posAction,
      String? negActionName,
      Function? negAction,
    })
    fn,
  ) {
    _showMessageOverride = fn;
  }

  static void resetToDefault() {
    _showLoadingOverride = null;
    _removeLoadingOverride = null;
    _showMessageOverride = null;
  }

  static void showLoading({
    required BuildContext context,
    required String loadingText,
  }) {
    if (_showLoadingOverride != null) {
      _showLoadingOverride!(context: context, loadingText: loadingText);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            Text(loadingText, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  static void removeLoading({required BuildContext context}) {
    if (_removeLoadingOverride != null) {
      _removeLoadingOverride!(context: context);
      return;
    }
    Navigator.pop(context);
  }

  static void showMessage({
    required BuildContext context,
    String? title,
    required String message,
    String? posActionName,
    Function? posAction,
    String? negActionName,
    Function? negAction,
  }) {
    if (_showMessageOverride != null) {
      _showMessageOverride!(
        context: context,
        title: title,
        message: message,
        posActionName: posActionName,
        posAction: posAction,
        negActionName: negActionName,
        negAction: negAction,
      );
      return;
    }
    List<Widget>? actions = [];
    if (posActionName != null) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            posAction?.call();
          },
          child: Text(
            posActionName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    if (negActionName != null) {
      actions.add(
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            negAction?.call();
          },
          child: Text(
            negActionName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        actions: actions,
      ),
    );
  }
}
