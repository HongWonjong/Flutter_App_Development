
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

