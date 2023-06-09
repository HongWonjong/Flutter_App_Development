import 'package:flutter/material.dart';
import 'package:food_cost_calculator_3_0/small one/custom_appbar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: "도움말 & 사용방법"),
      body: ListView(
        children: const [
          HelpItem(
            question: '어떤 앱인가요?',
            answer: '음식점의 운영을 돕기 위한 계산기 및 보고서 앱입니다.',
          ),
          HelpItem(
            question: '저장한 보고서는 어디서 볼 수 있나요?',
            answer: '좌측 상단의 메뉴 버튼을 눌러서 매출보고서를 클릭하시면, 작성하신 보고서들을 볼 수 있습니다.',
          ),
          HelpItem(
            question: '원가입력 페이지에 어떻게 정보를 입력해야 하나요?',
            answer: '예를 들어서 판매가 18000원인 후라이드 치킨이 있고, 한달에 2000개 판매된다고 한다면, 음식종류 => 후라이드 치킨, 개당 판매가격 => 18000원, 음식 판매량 => 2000개를 입력하시면 됩니다. \n\n 원가 항목에는 생닭, 식용유 등의 치킨 한마리에 필요한 항목들을 넣으시고, 이 항목이 판매량에 비례하여 발생하는지, 아니면 판매량과 상관없이 발생하는지를 선택하시면 됩니다. \n 마지막으로는 원가 항목의 금액을 입력하신 후, 저장 버튼을 누르면 내용이 원가 계산 페이지로 전송됩니다. \n\n 같은 음식의 다른 원가를 추가하시려면 이어서 원가 항목부터 아래의 내용들을 작성하고 저장하시면 되고, 다른 음식의 정보를 입력하시려면 처음부터 다시 작성하시면 됩니다.',
          ),
        ],
      ),
    );
  }
}

class HelpItem extends StatefulWidget {
  final String question;
  final String answer;

  const HelpItem({Key? key, required this.question, required this.answer})
      : super(key: key);

  @override
  _HelpItemState createState() => _HelpItemState();
}

class _HelpItemState extends State<HelpItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.question,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      subtitle: isExpanded ? Text(widget.answer,
      style: const TextStyle(fontSize: 18),) : null,
    );
  }
}
