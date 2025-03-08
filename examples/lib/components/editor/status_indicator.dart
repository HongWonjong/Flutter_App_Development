import 'package:flutter/material.dart';
import '../../models/app_theme.dart';
import '../../utils/color_utils.dart';

class StatusIndicator extends StatelessWidget {
  final bool isSaving;
  final bool isDirty;
  final AppTheme appTheme;
  final String savingText;
  final String changedText;

  const StatusIndicator({
    Key? key,
    required this.isSaving,
    required this.isDirty,
    required this.appTheme,
    this.savingText = '저장 중...',
    this.changedText = '변경됨',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return Positioned(
        right: 16,
        bottom: 16,
        child: Chip(
          label: Text(
            savingText,
            style: TextStyle(
              color: ColorUtils.contrastColor(appTheme.appBarColor),
            ),
          ),
          backgroundColor: appTheme.appBarColor,
        ),
      );
    } else if (isDirty) {
      return Positioned(
        right: 16,
        bottom: 16,
        child: Chip(
          label: Text(
            changedText,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
