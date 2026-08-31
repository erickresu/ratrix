import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Corner toast for rate create/edit/delete and auth success/error —
/// standard [ShadToast] via the app-wide [ShadToaster] in main.dart.
void showStatusToast(
  BuildContext context, {
  required String title,
  String? description,
  bool isError = false,
}) {
  final titleWidget = Text(title);
  final descriptionWidget = description != null ? Text(description) : null;
  ShadToaster.of(context).show(
    isError
        ? ShadToast.destructive(title: titleWidget, description: descriptionWidget)
        : ShadToast(title: titleWidget, description: descriptionWidget),
  );
}
