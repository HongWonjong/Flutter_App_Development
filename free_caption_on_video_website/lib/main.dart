import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/pages/upload_page.dart';
import 'package:free_caption_on_video_website/services/http_override.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:free_caption_on_video_website/services/transcribe_count_service.dart';
import 'firebase_options.dart';
import 'package:free_caption_on_video_website/providers/transcribe_count_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  // TranscribeCount 초기화 (한 번만 로드)
  final container = ProviderContainer();
  final transcribeCountService = TranscribeCountService();
  try {
    final snapshot = await transcribeCountService.getTranscribeCounts().first;
    if (snapshot.exists) {
      container.read(transcribeCountProvider.notifier).state = snapshot.data() as Map<String, dynamic>;
    }
  } catch (e) {
    print('[main] Failed to initialize transcribe count: $e');
    container.read(transcribeCountProvider.notifier).state = null;
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const UploadPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}