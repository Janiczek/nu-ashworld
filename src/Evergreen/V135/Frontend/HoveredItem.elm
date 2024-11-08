module Evergreen.V135.Frontend.HoveredItem exposing (..)

import Evergreen.V135.Data.FightStrategy.Help
import Evergreen.V135.Data.Item.Kind
import Evergreen.V135.Data.Perk
import Evergreen.V135.Data.Skill
import Evergreen.V135.Data.Special
import Evergreen.V135.Data.Special.Perception
import Evergreen.V135.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V135.Data.Perk.Perk
    | HoveredTrait Evergreen.V135.Data.Trait.Trait
    | HoveredSpecial Evergreen.V135.Data.Special.Type
    | HoveredSkill Evergreen.V135.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V135.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V135.Data.Special.Perception.PerceptionLevel
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
    | HoveredItem Evergreen.V135.Data.Item.Kind.Kind
