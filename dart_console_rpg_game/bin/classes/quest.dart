
class Quest {
  final String quest_name;
  final String quest_description;
  final String monster_name;
  final int monster_kill_count;
  final int reward_gold;
  bool is_completed; // 퀘스트 완료 여부
  bool is_accepted; // 퀘스트 수주 여부

  Quest(this.quest_name, this.quest_description, this.monster_name, this.monster_kill_count, this.reward_gold,
      {this.is_completed = false, this.is_accepted = false});
}

final List<Quest> questList = [
  Quest(
    "슬라임 잡기",
    "슬라임은 다양한 윤활유로 쓰입니다.",
    "슬라임", // 처치해야 하는 몬스터의 이름 => RpgGame 클래스 내의 퇴치한 몬스터를 적는 맵의 요소들의 키와 같도록 함.
    5, // 처치해야 하는 몬스터 개수
    50, // 처치 시 플레이어에게 주어질 골드
  ),
  Quest(
    "고블린들은 마을로 자주 숨어들어 경범죄를 저지릅니다. 이들의 수가 늘어나지 못하게 지속적으로 관리해야 합니다.",
    "너 고블린 죽여라",
    "고블린", //
    5,
    75,
  ),
  Quest(
    "웨어울프로 변한 일가족",
    "마을에서 살던 신혼부부가 알고보니 웨어울프 였습니다. 도주한 이들을 처치해주세요.",
    "웨어울프",
    2,
    150,
  ),
  Quest(
    "미노타우르스 퇴치",
    "미노타우르스의 뿔을 가공해서 장식품을 만들어야 합니다.",
    "미노타우르스",
    1,
    200,
  ),

];