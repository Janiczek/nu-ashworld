module Evergreen.V132.Frontend.HoveredItem exposing (..)

import Evergreen.V132.Data.FightStrategy.Help
import Evergreen.V132.Data.Perk
import Evergreen.V132.Data.Skill
import Evergreen.V132.Data.Special
import Evergreen.V132.Data.Special.Perception
import Evergreen.V132.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V132.Data.Perk.Perk
    | HoveredTrait Evergreen.V132.Data.Trait.Trait
    | HoveredSpecial Evergreen.V132.Data.Special.Type
    | HoveredSkill Evergreen.V132.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V132.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V132.Data.Special.Perception.PerceptionLevel
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
