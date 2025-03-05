import 'dart:async';

import 'package:flutter/cupertino.dart';

class PositionUpdater {
  Timer? _debounce;

  void updatePosition(
      Map<String, dynamic> widgetData,
      DragUpdateDetails details,
      double screenWidth,
      double screenHeight,
      Map<String, Map<String, dynamic>> localWidgets,
      VoidCallback setState,
      ) {
    final position = widgetData['position'] as Map<String, dynamic>;
    position['xfactor'] = (position['xfactor'] as double? ?? 0.0) + details.delta.dx / screenWidth;
    position['yfactor'] = (position['yfactor'] as double? ?? 0.0) + details.delta.dy / screenHeight;
    position['xfactor'] = position['xfactor'].clamp(0.0, 1.0);
    position['yfactor'] = position['yfactor'].clamp(0.0, 1.0);
    localWidgets[widgetData['id']] = widgetData;
    setState();
  }

  void updateGuidelinePosition(
      Map<String, dynamic> guidelineData,
      DragUpdateDetails details,
      double screenWidth,
      double screenHeight,
      Map<String, Map<String, dynamic>> localGuidelines,
      VoidCallback setState,
      ) {
    final type = guidelineData['type'] as String;
    final delta = type == 'horizontal' ? details.delta.dy / screenHeight : details.delta.dx / screenWidth;
    guidelineData['position'] = (guidelineData['position'] as double? ?? 0.5) + delta;
    guidelineData['position'] = guidelineData['position'].clamp(0.0, 1.0);
    localGuidelines[guidelineData['id']] = guidelineData;
    setState();
  }

  void debouncedUpdate(Map<String, dynamic> data, Function(Map<String, dynamic>) onUpdate) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      onUpdate(data);
    });
  }

  void dispose() {
    _debounce?.cancel();
  }
}