import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_buttons.dart';
import 'package:free_caption_on_video_website/providers/language_provider.dart';
import 'package:free_caption_on_video_website/services/file_picker_services.dart';
import 'package:free_caption_on_video_website/services/indexdb_service.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final FilePickerService _filePickerService = FilePickerService();
  final IndexedDbService _indexedDbService = IndexedDbService();
  int? _videoKey;
  bool _isUploadChecked = false;

  Future<void> _onUploadPressed() async {
    final videoBytes = await _filePickerService.pickVideoFile();
    if (videoBytes != null) {
      final key = await _indexedDbService.saveVideo(videoBytes);
      setState(() {
        _videoKey = key;
        _isUploadChecked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비디오 업로드 및 저장 성공!')),
      );
    } else {
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
              onPressed: () {
                Navigator.pop(context);
              },
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

  void _onProcessPressed() {
    final isLanguageSelected = ref.read(isLanguageSelectedProvider);
    if (_isUploadChecked && isLanguageSelected) {
      final languagePair = ref.read(languageProvider);
      print(
          '처리 시작 - IndexedDB 키: $_videoKey, 언어: ${languagePair.sourceLanguage} -> ${languagePair.targetLanguage}');
      // TODO: ProcessingPage로 이동하거나 처리 로직 연결
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전 단계를 먼저 마쳐주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languagePair = ref.watch(languageProvider);
    final isLanguageSelected = ref.watch(isLanguageSelectedProvider);

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
                  Checkbox(
                    value: _isUploadChecked,
                    onChanged: null,
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 5),
                  const Text('index_db에 업로드 완료'),
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
                  Checkbox(
                    value: isLanguageSelected,
                    onChanged: null,
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 5),
                  Text(languagePair.sourceLanguage != null && languagePair.targetLanguage != null
                      ? '${languagePair.sourceLanguage} -> ${languagePair.targetLanguage}'
                      : '언어 미선택'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: '처리 시작',
                    onPressed: _onProcessPressed,
                  ),
                  const SizedBox(width: 10),
                  if (_isUploadChecked && isLanguageSelected) ...[
                    Checkbox(
                      value: true,
                      onChanged: null,
                      checkColor: Colors.white,
                      activeColor: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    const Text('번역 준비 완료'),
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