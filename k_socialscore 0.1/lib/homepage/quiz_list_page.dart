import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:k_socialscore/quizpage/answer_button.dart';
import '../overall_settings.dart';
import 'package:k_socialscore/quizpage/quiz_set_page.dart';
import 'package:k_socialscore/create_quiz_page/create_quiz_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  String _sortCriteria = 'views'; // 기본 정렬 기준을 조회수로 설정

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: initialBackgroundColor,
      appBar: AppBar(
        backgroundColor: initialBackgroundColor,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '퀴즈 리스트',
              style: TextStyle(
                  color: textColor,
                  fontSize: questionText
              ),
            ),
            ElevatedButton(
              style: answerButtonStyle,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text("로그아웃", style: TextStyle(fontSize: textSize, color: Colors.white)),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: identifySpaceColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '정렬 기준:',
                    style: TextStyle(
                      color: textColor,
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    dropdownColor: identifySpaceColor,
                    value: _sortCriteria,
                    items: const [
                      DropdownMenuItem(
                        value: 'views',
                        child: Text('조회수 순', style: TextStyle(color: textColor)),
                      ),
                      DropdownMenuItem(
                        value: 'createdAt',
                        child: Text('최신 순', style: TextStyle(color: textColor)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortCriteria = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const Text(descriptionText, style: TextStyle(color: textColor, fontSize: questionText)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth / 3 - 16; // 3열로 나누고, 패딩을 고려하여 크기 조정
                final cardHeight = constraints.maxHeight / 5 - 8; // 5행으로 나누고, 패딩을 고려하여 크기 조정

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('quiz_sets')
                      .orderBy(_sortCriteria, descending: true) // 정렬 기준 적용
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final quizSets = snapshot.data!.docs;
                    if (quizSets.isEmpty) {
                      return const Center(
                        child: Text(
                          'No quiz sets available',
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 한 행에 세 개의 아이템을 표시합니다.
                        childAspectRatio: cardWidth / cardHeight, // 아이템의 비율을 조정하여 5행을 만듭니다.
                        mainAxisSpacing: 8.0, // 아이템 간의 세로 간격
                        crossAxisSpacing: 8.0, // 아이템 간의 가로 간격
                      ),
                      itemCount: quizSets.length,
                      itemBuilder: (context, index) {
                        final quizSet = quizSets[index];
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: Card(
                            color: buttonColor,
                            child: InkWell(
                              onTap: () async {
                                // 조회수 증가
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser?.uid)
                                    .collection('quiz_sets')
                                    .doc(quizSet.id)
                                    .update({'views': FieldValue.increment(1)});

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizSetPage(quizSetId: quizSet.id),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      quizSet['title'],
                                      style: const TextStyle(
                                        color: textColor,
                                        fontSize: textSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis, // 긴 텍스트 생략
                                      maxLines: 1, // 최대 두 줄로 제한
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '조회수: ${quizSet['views']}',
                                      style: const TextStyle(color: textColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateQuizPage(), // 퀴즈 생성 페이지로 이동
            ),
          );
        },
        backgroundColor: identifySpaceColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}








