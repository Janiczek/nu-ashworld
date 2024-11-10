module Evergreen.V139.Frontend.HoveredItem exposing (..)

import Evergreen.V139.Data.FightStrategy.Help
import Evergreen.V139.Data.Item.Kind
import Evergreen.V139.Data.Perk
import Evergreen.V139.Data.Skill
import Evergreen.V139.Data.Special
import Evergreen.V139.Data.Special.Perception
import Evergreen.V139.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V139.Data.Perk.Perk
    | HoveredTrait Evergreen.V139.Data.Trait.Trait
    | HoveredSpecial Evergreen.V139.Data.Special.Type
    | HoveredSkill Evergreen.V139.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V139.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V139.Data.Special.Perception.PerceptionLevel
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
    | HoveredItem Evergreen.V139.Data.Item.Kind.Kind
