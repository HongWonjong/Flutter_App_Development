class Quiz {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String? image;
  final String answerExplanation;
  final int socialPointsGain; // 정답일 때 증가할 사회점수
  final int socialPointsLoss; // 오답일 때 감소할 사회점수

  Quiz({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.image,
    required this.answerExplanation,
    required this.socialPointsGain,
    required this.socialPointsLoss,
  });
}

List<Quiz> quizList = [
  Quiz(
    question:
        "질문 1: 2024년 대한민국의 예상 합계 출산율은 0.68로 예상이 되고 있는데요. 과연 이는 누구의 잘못일까요?",
    options: ["문재인(2017.5-2022.5)", "윤석열(2022.5~)", "여성가족부", "집에서 숨 쉬고 있던 이대남"],
    answerIndex: 3,
    image: 'assets/heart.png',
    // 예시 이미지 경로
    answerExplanation:
        "시대의 변화에 맞는 올바른 성 인식과 정치적 올바름, 여성을 보듬을 수 있는 재력과 인성, 의지할 수 있는 든든하고 건강한 신체, 학벌과 지성을 가지지 못한 우리 이십대 남성의 잘못은 아닐까요? 자꾸 게임 같은거 하지 말고 건실하게 사시기 바랍니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 2: 다음 중 가장 높은 산은?",
    options: ["에베레스트", "안나푸르나", "킬리만자로", "알프스"],
    answerIndex: 0,
    image: null,
    answerExplanation: "에베레스트 산은 세계에서 가장 높은 산입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 3: 다음 중 가장 빠른 자동차는?",
    options: ["페라리", "부가티", "포르쉐", "람보르기니"],
    answerIndex: 1,
    image: null,
    answerExplanation: "부가티 베이론은 세계에서 가장 빠른 자동차 중 하나입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question:
        "질문 4: 악! 본 해병이 화장실 사용의 허락을 요청드리려 함에 대해 그 요청을 드리는 것이 무례하지 않은지를 여쭤보아도 되는지를 확인하는 것을 묻는 것이 적절한지를 판단해주실 수 있는지에 대해 허락해주실 수 있는지 알고 싶은 점이 있음에 대해 질문드려도 되는지를 결정해주실 수 있는지를 말씀드려도 되는지를 허락해주실 수 있는지에 대해 알려주실 수 있는지를 여쭈어보는 것이 가능한지를 묻는 것을 문의해도 되는지를 가르쳐주실 수 있는지를 여쭈어보는 것이 무례하지 않은지를 판단해주실 수 있는지에 대해 확인받을 수 있는지를 여쭤보아도 되는지를 결정해주실 수 있는지에 대해 허락을 구하는 것을 여쭤보아도 되는지를 확인해주실 수 있는지를 가르쳐주실 수 있는지에 대해 말씀드려도 되는지를 허락해주실 수 있는지를 확인해도 되는지를 여쭤보아도 되는지를 결정해주실 수 있는지에 대해 허락을 구하는 것을 여쭈어보아도 되는지를 확인해주실 수 있는지에 대해 말씀드려도 되는지를 여쭈어보아도 되는지를 확인해주실 수 있는지에 대해 허락을 구하는 것을 여쭤보아도 되는지를 결정해주실 수 있는지를 말씀드려도 되는지를 여쭈어보아도 되는지를 허락해주실 수 있는지에 대해 여쭈어보아도 되는지를 허락해주실 수 있는지에 대해 여쭈어보아도 되는지를 결정해주실 수 있는지를 여쭈어보아도 되는지의 여부를 알고자 함에 대해 말씀드려도 되겠습니까? 악!?",
    options: ["새애끼...기열!", "새애끼...기합!", "좋아", "안돼"],
    answerIndex: 1,
    image: null,
    answerExplanation: "정답이다 아쎄이! 스에끼...기합!",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 5: 다음 중 가장 큰 바다는?",
    options: ["대서양", "인도양", "태평양", "남극해"],
    answerIndex: 2,
    image: null,
    answerExplanation: "태평양은 세계에서 가장 큰 바다입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 6: 다음 중 가장 많이 사용하는 언어는?",
    options: ["영어", "중국어", "스페인어", "힌디어"],
    answerIndex: 1,
    image: null,
    answerExplanation: "중국어는 세계에서 가장 많이 사용되는 언어입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 7: 다음 중 가장 오래된 책은?",
    options: ["성경", "코란", "베다", "이청현감"],
    answerIndex: 2,
    image: null,
    answerExplanation: "베다는 인도에서 가장 오래된 성경 중 하나입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 8: 다음 중 가장 큰 행성은?",
    options: ["지구", "화성", "목성", "금성"],
    answerIndex: 2,
    image: null,
    answerExplanation: "목성은 태양계에서 가장 큰 행성입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 9: 다음 중 가장 빠른 새는?",
    options: ["독수리", "참새", "매", "까마귀"],
    answerIndex: 2,
    image: null,
    answerExplanation: "매는 세계에서 가장 빠른 새입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
  Quiz(
    question: "질문 10: 다음 중 가장 긴 강은?",
    options: ["아마존", "나일강", "한강", "미시시피"],
    answerIndex: 1,
    image: null,
    answerExplanation: "나일강은 세계에서 가장 긴 강입니다.",
    socialPointsGain: 10,
    socialPointsLoss: 10,
  ),
];
