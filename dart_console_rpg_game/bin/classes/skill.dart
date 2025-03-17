class Skill{
  final String skill_name;
  final String skill_description;
  final int skill_mp_cost;
  final bool is_attack;
  final num skill_damage_calculation;
  final bool is_heal;
  final bool is_buff;
  final bool is_debuff;

  const Skill(this.skill_name, this.skill_description, this.skill_mp_cost, this.is_attack, this.skill_damage_calculation, this.is_heal, this.is_buff, this.is_debuff);
}