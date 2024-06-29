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

  final List<String> _participants = [];
  final Map<String, int> _scores = {};
  final TextEditingController _nameController = TextEditingController();

  void _addWords() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _controller.text.split(',').forEach((word) {
          _wordManager.addWord(word.trim());
        });
        _controller.clear();
      });
      _focusNode.requestFocus(); // 단어 추가 후 텍스트 필드에 포커스 설정
    }
  }

  void _addParticipant() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        _participants.add(_nameController.text);
        _scores[_nameController.text] = 0;
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
              backgroundColor: Colors.deepPurple[100],
              title: const Text('Random Word'),
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
      _scores[name] = (_scores[name] ?? 0) + 1;
    });
  }

  void _decreaseScore(String name) {
    setState(() {
      _scores[name] = (_scores[name] ?? 0) - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merong's catchmind helper"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 점수판과 랜덤 단어가 위로 정렬되도록 수정
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Column 내부 요소들이 가로로 확장되도록 수정
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
                        itemCount: _participants.length,
                        itemBuilder: (context, index) {
                          String participant = _participants[index];
                          return ListTile(
                            title: Text(participant),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.deepPurple),
                                  onPressed: () => _decreaseScore(participant),
                                ),
                                Text(_scores[participant].toString()),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.deepPurple),
                                  onPressed: () => _increaseScore(participant),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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


