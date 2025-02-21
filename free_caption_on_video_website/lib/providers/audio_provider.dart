// providers/audio_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

final audioProvider = StateProvider<Uint8List?>((ref) => null);