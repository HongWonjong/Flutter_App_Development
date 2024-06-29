import 'package:flutter/material.dart';
import 'logic.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final WordManager _wordManager = WordManager();
  final FocusNode _focusNode = FocusNode();

  final ParticipantManager _participantManager = ParticipantManager();
  final TextEditingController _nameController = TextEditingController();

  void _addWords() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text.split(',').forEach((word) {
          _wordManager.addWord(word.trim());
        });
        _controller.clear();
      });
      _focusNode.requestFocus();
    }
  }

  void _addParticipant() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _participantManager.addParticipant(_nameController.text);
        _nameController.clear();
      });
    }
  }

  void _removeWord(int index) {
    setState(() {
      _wordManager.removeWord(index);
    });
  }

  void _showRandomWord() {
    setState(() {
      if (_wordManager.words.isNotEmpty) {
        String randomWord = _wordManager.getRandomWord();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.deepPurple[50],
              title: const Text('이번 주제'),
              content: Text(randomWord),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _increaseScore(String name) {
    setState(() {
      _participantManager.increaseScore(name);
    });
  }

  void _decreaseScore(String name) {
    setState(() {
      _participantManager.decreaseScore(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final screenHeight = MediaQuery.of(context).size.height;
            final iconSize = screenHeight * 0.05; // 화면 높이의 5%
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Merong's catchmind helper"),
                Image.asset(
                  'assets/icon.png',
                  width: iconSize,
                  height: iconSize,
                ),
              ],
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '참가자 이름',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addParticipant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('참가자 추가'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListView.builder(
                        itemCount: _participantManager.participants.length,
                        itemBuilder: (context, index) {
                          String participant = _participantManager.participants[index];
                          int score = _participantManager.scores[participant] ?? 0;
                          int highestScore = _participantManager.getHighestScore();
                          bool isHighestScorer = score == highestScore;
                          return Container(
                            color: isHighestScorer ? Colors.orangeAccent[100] : Colors.transparent,
                            child: ListTile(
                              title: Text(
                                participant,
                                style: TextStyle(
                                  fontWeight: isHighestScorer ? FontWeight.bold : FontWeight.normal,
                                  color: isHighestScorer ? Colors.deepPurple : Colors.black,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(isHighestScorer? Icons.wine_bar_outlined : null, color: Colors.pink),
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.deepPurple),
                                    onPressed: () => _decreaseScore(participant),
                                  ),
                                  Text(
                                    score.toString(),
                                    style: TextStyle(
                                      fontSize: isHighestScorer ? 23 : 20, // 원하는 크기로 변경
                                      fontWeight: isHighestScorer ? FontWeight.bold : FontWeight.normal,
                                      color: isHighestScorer ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                                    onPressed: () => _increaseScore(participant),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '저장된 단어 수: ${_wordManager.words.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      labelText: '단어 입력(여러 개 입력 시 ,)',
                    ),
                    onSubmitted: (value) => _addWords(),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _addWords,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('단어 추가'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showRandomWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('랜덤 단어 보기'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListView.builder(
                        itemCount: _wordManager.words.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_wordManager.words[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.deepPurple),
                              onPressed: () => _removeWord(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.deepPurple[100],
    );
  }
}

// In logic.dart, add this method to ParticipantManager
class ParticipantManager {
  final List<String> _participants = [];
  final Map<String, int> _scores = {};

  List<String> get participants => _participants;
  Map<String, int> get scores => _scores;

  void addParticipant(String name) {
    _participants.add(name);
    _scores[name] = 0;
  }

  void increaseScore(String name) {
    if (_scores.containsKey(name)) {
      _scores[name] = (_scores[name] ?? 0) + 1;
    }
  }

  void decreaseScore(String name) {
    if (_scores.containsKey(name) && (_scores[name] ?? 0) > 0) {
      _scores[name] = (_scores[name] ?? 0) - 1;
    }
  }

  int getHighestScore() {
    if (_scores.isEmpty) {
      return 0;
    }
    return _scores.values.reduce((a, b) => a > b ? a : b);
  }
}
