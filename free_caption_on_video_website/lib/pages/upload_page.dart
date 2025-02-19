// pages/upload_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_buttons.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_checkbox.dart';
import 'package:free_caption_on_video_website/providers/language_provider.dart';
import 'package:free_caption_on_video_website/providers/video_provider.dart';
import 'package:free_caption_on_video_website/providers/process_provider.dart';
import 'package:free_caption_on_video_website/providers/ffmpeg_provider.dart';
import 'package:free_caption_on_video_website/services/file_picker_services.dart';
import 'package:free_caption_on_video_website/services/indexdb_service.dart';
import 'package:free_caption_on_video_website/services/ffmpeg_service.dart';
import 'package:free_caption_on_video_website/providers/ffmpeg_service_provider.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  late final FilePickerService _filePickerService;
  late final IndexedDbService _indexedDbService;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _filePickerService = FilePickerService();
    _indexedDbService = IndexedDbService();
  }

  Future<void> _onUploadPressed() async {
    final videoBytes = await _filePickerService.pickVideoFile();
    if (videoBytes != null) {
      final key = await _indexedDbService.saveVideo(videoBytes);
      ref.read(videoProvider.notifier).state = VideoState(
        videoKey: key,
        isUploaded: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비디오 업로드 및 저장 성공!')),
      );
    } else {
      ref.read(videoProvider.notifier).state = VideoState(
        videoKey: null,
        isUploaded: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비디오 선택을 취소했거나 오류가 발생했습니다.')),
      );
    }
  }

  void _onLanguageSelectPressed() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSourceLang = ref.read(languageProvider).sourceLanguage;
        String? tempTargetLang = ref.read(languageProvider).targetLanguage;
        return AlertDialog(
          title: const Text('언어 선택'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '음성 언어'),
                    value: tempSourceLang,
                    items: ['영어', '한국어', '일본어', '중국어']
                        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        tempSourceLang = value;
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '번역할 언어'),
                    value: tempTargetLang,
                    items: ['영어', '한국어', '일본어', '중국어']
                        .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        tempTargetLang = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (tempSourceLang != null && tempTargetLang != null) {
                  ref.read(languageProvider.notifier).state = LanguagePair(
                    sourceLanguage: tempSourceLang,
                    targetLanguage: tempTargetLang,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 언어를 선택해주세요.')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onProcessPressed() async {
    if (_isProcessing) {
      print('Processing already in progress, ignoring button press');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리 중입니다. 잠시 기다려주세요.')),
      );
      return;
    }

    _isProcessing = true;
    try {
      final isProcessReady = ref.read(processProvider);
      if (isProcessReady) {
        final videoState = ref.read(videoProvider);
        final languagePair = ref.read(languageProvider);
        print(
            '처리 시작 - IndexedDB 키: ${videoState.videoKey}, 언어: ${languagePair.sourceLanguage} -> ${languagePair.targetLanguage}');

        final videoBytes = await _indexedDbService.getVideo(videoState.videoKey!);
        if (videoBytes != null) {
          final ffmpegService = ref.read(ffmpegServiceProvider); // Provider에서 가져옴
          final audioBytes = await ffmpegService.extractAudio(videoBytes);
          if (audioBytes != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('오디오 추출 성공!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('오디오 추출 실패')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('비디오 데이터를 불러오지 못했습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전 단계를 먼저 마쳐주세요.')),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final languagePair = ref.watch(languageProvider);
    final isLanguageSelected = ref.watch(isLanguageSelectedProvider);
    final isProcessReady = ref.watch(processProvider);
    final ffmpegState = ref.watch(ffmpegProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('자막 번역 사이트'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: '비디오 업로드',
                    onPressed: _onUploadPressed,
                  ),
                  const SizedBox(width: 10),
                  CustomCheckbox(
                    isChecked: videoState.isUploaded,
                    text: 'index_db에 업로드 완료',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: '번역 언어 선택',
                    onPressed: _onLanguageSelectPressed,
                  ),
                  const SizedBox(width: 10),
                  CustomCheckbox(
                    isChecked: isLanguageSelected,
                    text: languagePair.sourceLanguage != null && languagePair.targetLanguage != null
                        ? '${languagePair.sourceLanguage} -> ${languagePair.targetLanguage}'
                        : '언어 미선택',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: '처리 시작',
                        onPressed: _onProcessPressed,
                      ),
                      const SizedBox(width: 10),
                      if (isProcessReady) ...[
                        CustomCheckbox(
                          isChecked: isProcessReady,
                          text: '번역 준비 완료',
                        ),
                      ],
                    ],
                  ),
                  if (isProcessReady) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isInitialized,
                          text: 'FFmpeg 초기화 완료',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isFsReady,
                          text: 'FS 모듈 준비 완료',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isInputWritten,
                          text: '입력 파일 쓰기 완료',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isCommandExecuted,
                          text: 'FFmpeg 명령어 실행 완료',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isOutputRead,
                          text: '출력 파일 읽기 완료',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        CustomCheckbox(
                          isChecked: ffmpegState.isAudioExtracted,
                          text: '오디오 추출 완료',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}