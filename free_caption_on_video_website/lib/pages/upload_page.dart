import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_app_bar.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_buttons.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/custom_checkbox.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/loading_overlay.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/memo_widget.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/status_row.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/audio_extraction_row.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/srt_modify_row.dart';
import 'package:free_caption_on_video_website/pages/upload_page_components/transcribe_count_widget.dart';
import 'package:free_caption_on_video_website/providers/language_provider.dart';
import 'package:free_caption_on_video_website/providers/video_provider.dart';
import 'package:free_caption_on_video_website/providers/process_provider.dart';
import 'package:free_caption_on_video_website/providers/ffmpeg_provider.dart';
import 'package:free_caption_on_video_website/providers/audio_provider.dart';
import 'package:free_caption_on_video_website/providers/whisper_provider.dart';
import 'package:free_caption_on_video_website/services/file_picker_services.dart';
import 'package:free_caption_on_video_website/services/indexdb_service.dart';
import 'package:free_caption_on_video_website/services/ffmpeg_service.dart';
import 'package:free_caption_on_video_website/services/whisper_service.dart';
import 'package:free_caption_on_video_website/style/responsive_sizes.dart';
import 'dart:html' as html;
import '../providers/srt_provider.dart';


class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  late final FilePickerService _filePickerService;
  late final IndexedDbService _indexedDbService;
  bool _isProcessing = false;
  String? _srtContent;

  @override
  void initState() {
    super.initState();
    _filePickerService = FilePickerService();
    _indexedDbService = IndexedDbService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ResponsiveSizes.init(context);
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'N/A';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  Future<void> _onUploadPressed() async {
    final videoBytes = await _filePickerService.pickVideoFile();

    ref.read(ffmpegProvider.notifier).state = FmpegState();
    ref.read(languageProvider.notifier).state = LanguagePair(sourceLanguage: null, targetLanguage: null);
    ref.read(ffmpegServiceProvider).reset();
    ref.read(whisperProvider.notifier).state = WhisperState();
    ref.read(srtModifyProvider.notifier).state = SrtModifyState();

    if (videoBytes != null) {
      debugPrint('비디오 업로드 시작: ${videoBytes.length} bytes');
      try {
        await ref.read(videoProvider.notifier).uploadVideo(videoBytes);
        debugPrint('비디오 업로드 성공');

        await ref.read(videoProvider.notifier).captureThumbnail();
        final videoState = ref.read(videoProvider);
        debugPrint('업로드 및 썸네일 처리 완료 - videoKey: ${videoState.videoKey}, thumbnail: ${videoState.thumbnail != null ? "있음" : "없음"}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비디오 업로드 및 썸네일 추출 성공!', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
          ),
        );
      } catch (e) {
        debugPrint('업로드 또는 썸네일 처리 실패: $e');
        ref.read(videoProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비디오 업로드 실패: $e', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
          ),
        );
      }
    } else {
      debugPrint('비디오 선택 취소');
      ref.read(videoProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비디오 선택을 취소했거나 오류가 발생했습니다.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
        ),
      );
    }
    setState(() {});
  }

  void _onLanguageSelectPressed() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSourceLang = ref.read(languageProvider).sourceLanguage;
        String? tempTargetLang = ref.read(languageProvider).targetLanguage;
        return AlertDialog(
          title: Text('언어 선택', style: TextStyle(fontSize: ResponsiveSizes.textSize(5))),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '음성 언어'),
                    value: tempSourceLang,
                    items: ['en', 'ko', 'jp', 'cn']
                        .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang, style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                    ))
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
                    items: ['en', 'ko', 'jp', 'cn']
                        .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang, style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                    ))
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
              child: Text('취소', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
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
                    SnackBar(
                      content: Text('모든 언어를 선택해주세요.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
                    ),
                  );
                }
              },
              child: Text('확인', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onProcessPressed() async {
    if (_isProcessing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('처리 중입니다. 잠시 기다려주세요.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
        ),
      );
      return;
    }

    _isProcessing = true;
    try {
      final isProcessReady = ref.read(processProvider);
      if (isProcessReady) {
        final videoState = ref.read(videoProvider);
        final videoBytes = await _indexedDbService.getVideo(videoState.videoKey!);
        if (videoBytes != null) {
          final ffmpegService = ref.read(ffmpegServiceProvider);
          final audioBytes = await ffmpegService.extractAudio(videoBytes);
          if (audioBytes != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('오디오 추출 성공!', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('오디오 추출 실패', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('비디오 데이터를 불러오지 못했습니다.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전 단계를 먼저 마쳐주세요.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
          ),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _onTranscribePressed() async {
    final whisperState = ref.watch(whisperProvider);

    if (whisperState.isRequesting) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transcription is in progress. Please wait.', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
        ),
      );
      return;
    }

    try {
      var audioData = ref.read(audioProvider);
      if (audioData == null) {
        final errorMsg = 'Audio data is null in audioProvider';
        print("[ERROR] $errorMsg");
        ref.read(whisperProvider.notifier).state = whisperState.copyWith(
          isRequesting: false,
          finalError: errorMsg,
          hasErrorDisplayed: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
          ),
        );
        return;
      }

      Uint8List audioBytes = audioData is Uint8List ? audioData : throw 'Invalid audio data type';

      final languagePair = ref.read(languageProvider);
      if (languagePair.sourceLanguage == null) {
        final errorMsg = 'Source language is not selected';
        print("[ERROR] $errorMsg");
        ref.read(whisperProvider.notifier).state = whisperState.copyWith(
          isRequesting: false,
          finalError: errorMsg,
          hasErrorDisplayed: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg, style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
          ),
        );
        return;
      }

      print("[INFO] Transcription 시작...");
      final whisperService = ref.read(whisperServiceProvider);
      await for (var update in whisperService.transcribeAudioToSrt(audioBytes, languagePair.sourceLanguage!)) {
        print("[INFO] Update: $update");
        if (update['status'] == 'completed') {
          setState(() {
            _srtContent = update['translation'];
            final originalSrt = update['original'];
            ref.read(srtModifyProvider.notifier).setSrtContent(_srtContent!, originalSrt);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcription successful!', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
            ),
          );
        } else if (update['status'] == 'error') {
          final errorMsg = update['message'] ?? 'Unknown error occurred';
          print("[ERROR] Transcription 실패: $errorMsg");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transcription failed: $errorMsg', style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
            ),
          );
        }
      }
    } catch (e) {
      final errorMsg = 'Unexpected error: $e\nStacktrace: ${StackTrace.current}';
      print("[ERROR] $errorMsg");
      ref.read(whisperProvider.notifier).state = whisperState.copyWith(
        isRequesting: false,
        finalError: errorMsg,
        hasErrorDisplayed: true,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: TextStyle(fontSize: ResponsiveSizes.textSize(3))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = ref.watch(videoProvider);
    final languagePair = ref.watch(languageProvider);
    final isLanguageSelected = ref.watch(isLanguageSelectedProvider);
    final isProcessReady = ref.watch(processProvider);
    final ffmpegState = ref.watch(ffmpegProvider);
    final audioData = ref.watch(audioProvider);
    final whisperState = ref.watch(whisperProvider);
    final srtModifyState = ref.watch(srtModifyProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack( // Stack으로 감싸 오버레이 추가
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveSizes.h5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: MemoWidget()),
                      SizedBox(width: ResponsiveSizes.h5),
                      TranscribeCountWidget(),
                    ],
                  ),
                  SizedBox(height: ResponsiveSizes.h5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomButton(
                            text: 'mp4 업로드',
                            onPressed: _onUploadPressed,
                          ),
                          SizedBox(height: ResponsiveSizes.h10),
                          CustomButton(
                            text: '번역 언어',
                            onPressed: _onLanguageSelectPressed,
                          ),
                          SizedBox(height: ResponsiveSizes.h10),
                          CustomButton(
                            text: '오디오 추출',
                            onPressed: _onProcessPressed,
                          ),
                        ],
                      ),
                      SizedBox(width: ResponsiveSizes.h10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomCheckbox(
                              isChecked: videoState.isUploaded,
                              text: 'index_db 업로드',
                            ),
                            if (videoState.isUploaded && videoState.videoFileSize != null)
                              Padding(
                                padding: EdgeInsets.only(left: ResponsiveSizes.h5),
                                child: Text(
                                  '용량: ${_formatFileSize(videoState.videoFileSize)}',
                                  style: TextStyle(fontSize: ResponsiveSizes.textSize(2)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            SizedBox(height: ResponsiveSizes.h2),
                            CustomCheckbox(
                              isChecked: isLanguageSelected,
                              text: languagePair.sourceLanguage != null && languagePair.targetLanguage != null
                                  ? '${languagePair.sourceLanguage} -> ${languagePair.targetLanguage}'
                                  : '언어 미선택',
                            ),
                            SizedBox(height: ResponsiveSizes.h2),
                            CustomCheckbox(
                              isChecked: isProcessReady,
                              text: '번역 준비 완료',
                            ),
                            if (isProcessReady) ...[
                              SizedBox(height: ResponsiveSizes.h2),
                              StatusRow(
                                isChecked: ffmpegState.isInitialized,
                                text: 'FFmpeg 초기화 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isInitialized && ffmpegState.hasErrorDisplayed,
                              ),
                              SizedBox(height: ResponsiveSizes.h2),
                              StatusRow(
                                isChecked: ffmpegState.isFsReady,
                                text: 'FS 모듈 준비 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isFsReady && ffmpegState.hasErrorDisplayed && ffmpegState.isInitialized,
                              ),
                              SizedBox(height: ResponsiveSizes.h2),
                              StatusRow(
                                isChecked: ffmpegState.isInputWritten,
                                text: '입력 파일 쓰기 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isInputWritten && ffmpegState.hasErrorDisplayed && ffmpegState.isFsReady,
                              ),
                              SizedBox(height: ResponsiveSizes.h2),
                              StatusRow(
                                isChecked: ffmpegState.isCommandExecuted,
                                text: 'FFmpeg 명령어 실행 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isCommandExecuted && ffmpegState.hasErrorDisplayed && ffmpegState.isInputWritten,
                              ),
                              SizedBox(height: ResponsiveSizes.h2),
                              StatusRow(
                                isChecked: ffmpegState.isOutputRead,
                                text: '출력 파일 읽기 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isOutputRead && ffmpegState.hasErrorDisplayed && ffmpegState.isCommandExecuted,
                              ),
                              SizedBox(height: ResponsiveSizes.h2),
                              AudioExtractionRow(
                                isChecked: ffmpegState.isAudioExtracted,
                                text: '오디오 추출&압축 완료',
                                errorMessage: ffmpegState.errorMessage,
                                hasErrorDisplayed: !ffmpegState.isAudioExtracted && ffmpegState.hasErrorDisplayed && ffmpegState.isOutputRead,
                                audioFileSize: ffmpegState.audioFileSize,
                                audioData: audioData,
                                formatFileSize: _formatFileSize,
                                onDownloadPressed: () {
                                  final blob = html.Blob([audioData], 'audio/mpeg');
                                  final url = html.Url.createObjectUrlFromBlob(blob);
                                  final anchor = html.AnchorElement(href: url)
                                    ..setAttribute('download', 'audio.mp3')
                                    ..click();
                                  html.Url.revokeObjectUrl(url);
                                },
                                onTranscribePressed: _onTranscribePressed,
                                srtContent: _srtContent,
                                onSrtDownloadPressed: () {
                                  final blob = html.Blob([_srtContent!], 'text/srt');
                                  final url = html.Url.createObjectUrlFromBlob(blob);
                                  final anchor = html.AnchorElement(href: url)
                                    ..setAttribute('download', 'original_subtitles.srt')
                                    ..click();
                                  html.Url.revokeObjectUrl(url);
                                },
                              ),
                              if (ffmpegState.isAudioExtracted) ...[
                                SizedBox(height: ResponsiveSizes.h2),
                                StatusRow(
                                  isChecked: whisperState.transcriptionStatus == 'requestSent' ||
                                      whisperState.transcriptionStatus == 'processing' ||
                                      whisperState.transcriptionStatus == 'completed',
                                  text: whisperState.transcriptionStatus == 'requestSent'
                                      ? '서버로 요청을 전송 중입니다...'
                                      : whisperState.transcriptionStatus == 'processing' || whisperState.transcriptionStatus == 'completed'
                                      ? '요청이 성공적으로 전송되었습니다.'
                                      : '서버로의 요청 전송을 기다리고 있습니다.',
                                  errorMessage: whisperState.transcriptionStatus == 'error' ? whisperState.requestError : null,
                                  hasErrorDisplayed: whisperState.transcriptionStatus == 'error' && whisperState.requestError != null,
                                ),
                                SizedBox(height: ResponsiveSizes.h2),
                                StatusRow(
                                  isChecked: whisperState.transcriptionStatus == 'processing' || whisperState.transcriptionStatus == 'completed',
                                  text: whisperState.transcriptionStatus == 'processing'
                                      ? '서버에서 오디오를 처리 중입니다... 예상 시간: ${whisperState.estimatedTime ?? "계산 중"})'
                                      : whisperState.transcriptionStatus == 'completed'
                                      ? '오디오 처리가 완료되었습니다.'
                                      : '서버에서 오디오를 처리하기 위해 대기 중입니다.',
                                  hasErrorDisplayed: whisperState.transcriptionStatus == 'error' && whisperState.requestError != null,
                                ),
                                Text(
                                  "whisperState.estimatedTime: ${whisperState.estimatedTime ?? ''}",
                                  style: TextStyle(fontSize: ResponsiveSizes.textSize(2)),
                                ),
                                SizedBox(height: ResponsiveSizes.h2),
                                StatusRow(
                                  isChecked: whisperState.transcriptionStatus == 'completed',
                                  text: whisperState.transcriptionStatus == 'completed'
                                      ? 'SRT 생성 완료'
                                      : 'SRT 대기 중 (밀린 요청이 많으면 예상 시간보다 늦어질 수 있습니다.)',
                                  hasErrorDisplayed: whisperState.transcriptionStatus == 'error' && whisperState.requestError != null,
                                ),
                                if (whisperState.transcriptionStatus == 'processing')
                                  Padding(
                                    padding: EdgeInsets.only(top: ResponsiveSizes.h2),
                                    child: LinearProgressIndicator(
                                      value: whisperState.progress / 100.0,
                                      minHeight: ResponsiveSizes.h2,
                                    ),
                                  ),
                                if (whisperState.transcriptionStatus == 'completed') ...[
                                  SizedBox(height: ResponsiveSizes.h2),
                                  SrtModifyRow(),
                                ],
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 오버레이 추가: 요청 중일 때만 표시
          LoadingOverlay(isVisible: whisperState.isRequesting),
        ],
      ),
    );
  }
}
