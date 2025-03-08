import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';
import 'draggable_element_widget.dart';

class ImageElementWidget extends StatelessWidget {
  final ImageElement element;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Function(String) onRemove;
  final Function(String, Offset) onPositionChanged;
  final Function(String, double, double) onSizeChanged;
  final Function(String)? onEdit;

  const ImageElementWidget({
    Key? key,
    required this.element,
    this.width = 200.0,
    this.height = 150.0,
    required this.backgroundColor,
    required this.textColor,
    required this.onRemove,
    required this.onPositionChanged,
    required this.onSizeChanged,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableElementWidget(
      element: element,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onRemove: onRemove,
      onPositionChanged: onPositionChanged,
      onSizeChanged: onSizeChanged,
      onEdit: onEdit,
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(element.path),
        fit: BoxFit.cover,
        width: width,
        height: height,
      ),
    );
  }
}
