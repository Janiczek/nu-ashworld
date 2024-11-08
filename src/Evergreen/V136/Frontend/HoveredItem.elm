module Evergreen.V136.Frontend.HoveredItem exposing (..)

import Evergreen.V136.Data.FightStrategy.Help
import Evergreen.V136.Data.Item.Kind
import Evergreen.V136.Data.Perk
import Evergreen.V136.Data.Skill
import Evergreen.V136.Data.Special
import Evergreen.V136.Data.Special.Perception
import Evergreen.V136.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V136.Data.Perk.Perk
    | HoveredTrait Evergreen.V136.Data.Trait.Trait
    | HoveredSpecial Evergreen.V136.Data.Special.Type
    | HoveredSkill Evergreen.V136.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V136.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V136.Data.Special.Perception.PerceptionLevel
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
    | HoveredItem Evergreen.V136.Data.Item.Kind.Kind
