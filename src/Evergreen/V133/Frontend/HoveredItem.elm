module Evergreen.V133.Frontend.HoveredItem exposing (..)

import Evergreen.V133.Data.FightStrategy.Help
import Evergreen.V133.Data.Perk
import Evergreen.V133.Data.Skill
import Evergreen.V133.Data.Special
import Evergreen.V133.Data.Special.Perception
import Evergreen.V133.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V133.Data.Perk.Perk
    | HoveredTrait Evergreen.V133.Data.Trait.Trait
    | HoveredSpecial Evergreen.V133.Data.Special.Type
    | HoveredSkill Evergreen.V133.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V133.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V133.Data.Special.Perception.PerceptionLevel
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
