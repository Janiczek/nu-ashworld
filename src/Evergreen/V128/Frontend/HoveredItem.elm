module Evergreen.V128.Frontend.HoveredItem exposing (..)

import Evergreen.V128.Data.FightStrategy.Help
import Evergreen.V128.Data.Perk
import Evergreen.V128.Data.Skill
import Evergreen.V128.Data.Special
import Evergreen.V128.Data.Special.Perception
import Evergreen.V128.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V128.Data.Perk.Perk
    | HoveredTrait Evergreen.V128.Data.Trait.Trait
    | HoveredSpecial Evergreen.V128.Data.Special.Type
    | HoveredSkill Evergreen.V128.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V128.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V128.Data.Special.Perception.PerceptionLevel
    | HoveredSequence
    | HoveredMaxHP
    | HoveredActionPoints
    | HoveredArmorClass
    | HoveredCriticalChance
    | HoveredDamageThreshold
    | HoveredDamageResistance
    | HoveredHealOverTime
    | HoveredHealUsingTick
