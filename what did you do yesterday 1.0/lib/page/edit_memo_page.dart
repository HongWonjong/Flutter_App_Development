import 'package:flutter/material.dart';
import 'package:freedomcompass/component/app_bar.dart';
import 'package:freedomcompass/style/text_style.dart';
import 'package:freedomcompass/l10n/language.dart';
import 'package:freedomcompass/style/color.dart';
import 'package:freedomcompass/component/sized_box.dart';
import 'package:freedomcompass/style/button_style.dart';
import 'package:freedomcompass/component/memo_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freedomcompass/function/memo_editing_function.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EditMemoPage extends StatefulWidget {
  final String memoId; // 편집하려는 메모의 고유번호

  EditMemoPage({required this.memoId}); // 생성자에 메모의 고유번호를 전달받음

  @override
  _EditMemoPageState createState() => _EditMemoPageState();
}

class _EditMemoPageState extends State<EditMemoPage> {
  final TextEditingController _memoController = TextEditingController(); // 텍스트 필드의 컨트롤러
  // Firestore 인스턴스 생성
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // initState에서 메모의 내용을 불러오기
    _loadMemoContent();
  }

  // 메모의 내용을 불러와서 텍스트 필드에 설정
  void _loadMemoContent() {
    FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .collection('memoes')
        .doc(widget.memoId) // 위젯에서 전달받은 메모의 고유번호 사용
        .get()
        .then((DocumentSnapshot memoSnapshot) {
      if (memoSnapshot.exists) {
        String? currentContents = (memoSnapshot.data() as Map<String, dynamic>?)?['contents'] as String? ?? "";

        // 텍스트 필드에 현재 내용 설정
        _memoController.text = currentContents;
      } else {
        // 메모가 존재하지 않는 경우
        print('해당 메모를 찾을 수 없습니다.');
      }
    }).catchError((error) {
      print('메모 불러오기 중 오류 발생: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const CustomAppBar(titleText: mainpage_lan.mainPageTitle),
      body: Container(
        color: AppColors.centerColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AdaptiveSizedBox(),
              MediumButton(
                buttonColor: AppColors.mainPageButtonColor,
                onPressed: () {
                  // 입력된 메모 내용 사용 가능
                  String memoText = _memoController.text;
                  print('입력된 메모: $memoText');

                  // Memo 저장 함수 호출
                  // 여기서는 편집 함수 호출
                  editMemo(widget.memoId, memoText, context);
                },
                buttonText: createpage_lan.createfinished,
                textStyle: AdaptiveText.mediumTextStyle(context, color: AppColors.mainPageButtonTextColor),
              ),
              const AdaptiveSizedBox(),
              // 텍스트 필드 추가
              MemoTextFieldWidget(memoController: _memoController),
            ],
          ),
        ),
      ),
    );
  }
}
