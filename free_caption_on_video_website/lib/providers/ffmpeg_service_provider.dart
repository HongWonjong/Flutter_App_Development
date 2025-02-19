import '../services/ffmpeg_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final ffmpegServiceProvider = Provider<FfmpegService>((ref) => FfmpegService(ref));
