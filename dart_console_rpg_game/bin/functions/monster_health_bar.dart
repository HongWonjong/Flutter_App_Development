String getHealthBar(int currentHp, int maxHp) { // 몬스터 체력 표시용
  const int barLength = 10;
  int filledBlocks = ((currentHp / maxHp) * barLength).round();
  filledBlocks = filledBlocks.clamp(0, barLength);
  String bar = "█" * filledBlocks + "□" * (barLength - filledBlocks);
  return bar;
}