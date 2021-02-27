// PSEUDOCODE

// determining tohit:

// used GLOBALLY in calculations (all =0 as default):

int distmod1;
int distmod2;
int dist; // used as accumulator
int tohit;
int use_ac; // is armor class used
int is_ranged; // is attack ranged
int perception;


int determine_tohit_func() {

  if (target_valid) use_ac = 1; // target_valid <=> target_id != 0

  if (attack_is_generic_fo1_unarmed_attack) tohit = attacker_skill_unarmed;
    else
    if (attack_with_weapon) {
      tohit = attacker_skill_appropriate; // checked for small guns etc.

      if (weapon_is_ranged) apply_distance_modifier(); // this will also mark the attack as ranged

      if (attacker_is_player)
        if (player_is_one_hander)
          { if (weapon_is_two_handed) tohit-=40; else tohit+=20; }

      int strength=attacker_stat_strength;
      if (attacker_is_player)
        if (player_have_weapon_handling) strength+=3;
      if (weapon_strength_req > strength) tohit-=20*(weapon_strength_req - strength);

      if (weapon_perk == accurate) tohit+=20;
    }
    else
    if (attack_without_weapon) tohit = attacker_skill_unarmed; // fo2 attacks without weapons (including special punches etc.)
  // if attack_type == invalid then tohit == 0, still.

  if (use_ac)
    if (target_ac + weapon_ac_mod > 0) tohit -= target_ac + weapon_ac_mod; // weapon_ac_mod is usually negative

  if (attack_is_ranged) tohit+=location_penalty; // which is negative
    else tohit+=location_penalty/2;

  if (target_is_multihex) tohit+=15; // centaurs, deathclaws etc.

  if (attacker_is_player) {
    int light;
    if (!target_valid) light=0;
    else {
      light = target_lumination;
      if (weapon_perk == night_sight) light=0x10000;
    }
    if (0x9999 < light <= 0x0cccc) tohit-=10;
    if (0x6666 < light <= 0x9999)  tohit-=25;
    if (         light <= 0x6666)  tohit-=40;
  } // light is not applied for npcs

  if (attacker_have_damaged_eye) tohit-=25;

  if (target_is_lying) tohit+=40;

  if (attacker_is_not_in_player_team) {
    if (combat_difficulty == wimpy) tohit+=20;
    if (combat_difficulty == rough) tohit-=20;
  }

  if (tohit > 95) tohit = 95;

  return tohit;
}

int apply_distance_modifier() {
  attack_is_ranged = 1;

  if (weapon_perk == long_range) distmod1 = 4;
    else if (weapon_perk == scope_range) {distmod1 = 5; distmod2 = 8; }
      else distmod1 = 2;

  perception = attacker_perception;

  if (target_invalid) dist = 0;
    else dist = distance_between_attacker_and_target; // this is distance between central hexes, -1 when attacker is multihex, -1 when target is multihex

  if (dist < distmod2) dist+=distmod2; // this happens when target is within minimum range of an scoped range weapon
  else {
    if (attacker_is_player) dist-=(perception-2)*distmod1; // player nerfed
      else dist-=perception*distmod1;
  }

  if (-2*perception > dist) dist = -2*perception;

  if (attacker_is_player) dist-=2*player_sharpshooter_level;

  if (dist >= 0) { if (attacker_eye_damage) dist*=-12; else dist*=-4;}
  else dist*=-4;

  if (!(attack_with_norange_argument && (dist<=0))) tohit+=dist;

  // technically, here should be dist=0; and from now on, dist will be used as accumulator

  if (!target_invalid && !attack_with_norange_argument) tohit-=10*objects_between_attacker_and_target;
    // it's not known which objects are taken into account; probably it has something to do with ShootThru proto flags
    // EDIT: probably it's just a critter counter, however strange results were measured when they were multihex
}
