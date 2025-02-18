import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/providers/language_provider.dart';
import 'package:free_caption_on_video_website/providers/video_provider.dart';

final processProvider = Provider<bool>((ref) {
  final videoState = ref.watch(videoProvider);
  final isLanguageSelected = ref.watch(isLanguageSelectedProvider);
  return videoState.isUploaded && isLanguageSelected;
});