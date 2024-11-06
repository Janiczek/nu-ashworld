module Evergreen.V129.Frontend.HoveredItem exposing (..)

import Evergreen.V129.Data.FightStrategy.Help
import Evergreen.V129.Data.Perk
import Evergreen.V129.Data.Skill
import Evergreen.V129.Data.Special
import Evergreen.V129.Data.Special.Perception
import Evergreen.V129.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V129.Data.Perk.Perk
    | HoveredTrait Evergreen.V129.Data.Trait.Trait
    | HoveredSpecial Evergreen.V129.Data.Special.Type
    | HoveredSkill Evergreen.V129.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V129.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V129.Data.Special.Perception.PerceptionLevel
    | HoveredSequence
    | HoveredMaxHP
    | HoveredActionPoints
    | HoveredArmorClass
    | HoveredCriticalChance
    | HoveredDamageThreshold
    | HoveredDamageResistance
    | HoveredHealOverTime
    | HoveredHealUsingTick
    | HoveredPerkRate
    | HoveredSkillRate
