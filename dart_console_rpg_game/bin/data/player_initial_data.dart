import '../classes/item.dart';
import '../classes/skill.dart';

// 초기 인벤토리는 이렇게
final List<Item> initialInventory = [
  Item("gold", false, 1, false, 50, "이 작은 콘솔 세상의 기본 거래 단위입니다."),
  Item("진짜_그냥_나뭇가지", false, 1, true, 1, "이건 왜 들고 계신거죠?", atk: 3),
  Item("빨간_포션", true, 10, false, 1, "제픔 설명: 타우린, 고농축 카페인, 합성 착향 색소, 아르기닌 500mg 포함", hp: 50),
];

// 초기 장착 아이템은 없다.
final List<Item> initialEquippedItems = [];

// 초기 스킬셋은 이렇게
final List<Skill> initialSkills = [
  Skill("광분", "일시적으로 공격력을 증가시킵니다.", 10, false, 10, false, true, false),
  Skill("방패 올리기", "방패를 들어 방어력을 일시적으로 증가시킵니다. (방패가 있어야 사용 가능)", 10, false, 10, false, true, false),
];