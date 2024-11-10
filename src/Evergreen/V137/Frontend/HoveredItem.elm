module Evergreen.V137.Frontend.HoveredItem exposing (..)

import Evergreen.V137.Data.FightStrategy.Help
import Evergreen.V137.Data.Item.Kind
import Evergreen.V137.Data.Perk
import Evergreen.V137.Data.Skill
import Evergreen.V137.Data.Special
import Evergreen.V137.Data.Special.Perception
import Evergreen.V137.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V137.Data.Perk.Perk
    | HoveredTrait Evergreen.V137.Data.Trait.Trait
    | HoveredSpecial Evergreen.V137.Data.Special.Type
    | HoveredSkill Evergreen.V137.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V137.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V137.Data.Special.Perception.PerceptionLevel
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
    | HoveredItem Evergreen.V137.Data.Item.Kind.Kind
