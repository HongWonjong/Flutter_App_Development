import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:website/function/listen_for_response.dart';
import 'package:website/function/response_processing.dart';
import 'package:website/function/speech_recognition.dart';


class AIVtuberWidget extends StatefulWidget {
  const AIVtuberWidget({super.key});

  @override
  _AIVtuberWidgetState createState() {
    return _AIVtuberWidgetState();
  }
}

class _AIVtuberWidgetState extends State<AIVtuberWidget> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final String docId = "GPT35_VTuber";
  final String messageFieldName = "gpt35_prompt";
  final String responseFieldName = "gpt35_response";
  final String orderByField = "status.created_at";
  late SpeechRecognitionService _speechService;
  late ResponseProcessingService _responseService;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechRecognitionService(
      onResult: _onSpeechResult,
      onListeningStateChanged: _onListeningStateChanged,
    );
    _responseService = ResponseProcessingService();
    _speechService.initSpeech(context);
  }

  void _onSpeechResult(String text) {
    _speechService.sendTextToFirestore(text, uid, docId, messageFieldName);
  }

  void _onListeningStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Vtuber")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Image.asset(_speechService.currentImage),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _speechService.text,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () => _speechService.listen(context),
              child: Icon(_speechService.isListening ? Icons.mic : Icons.mic_none),
            ),
            SizedBox(
              height: 400,
              child: StreamBuilder<List<String>>(
                stream: listenForResponses(docId, messageFieldName, responseFieldName, orderByField),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No responses yet');
                  } else {
                    final responses = snapshot.data!;
                    if (responses.isNotEmpty) {
                      for (final response in responses) {
                        if (response != _responseService.lastResponseId) {
                          _responseService.addResponseToQueue(response);
                          _responseService.lastResponseId = response;
                        }
                      }
                    }
                    return ListView(
                      shrinkWrap: true,
                      children: responses.map((response) => ListTile(title: Text(response))).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

