import 'package:flutter/material.dart';

Alignment getAlignment(String alignment) {
  switch (alignment) {
    case 'left':
      return Alignment.centerLeft;
    case 'right':
      return Alignment.centerRight;
    case 'center':
    default:
      return Alignment.center;
  }
}