module Evergreen.V112.Frontend.HoveredItem exposing (..)

import Evergreen.V112.Data.FightStrategy.Help
import Evergreen.V112.Data.Perk
import Evergreen.V112.Data.Skill
import Evergreen.V112.Data.Special
import Evergreen.V112.Data.Special.Perception
import Evergreen.V112.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V112.Data.Perk.Perk
    | HoveredTrait Evergreen.V112.Data.Trait.Trait
    | HoveredSpecial Evergreen.V112.Data.Special.Type
    | HoveredSkill Evergreen.V112.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V112.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V112.Data.Special.Perception.PerceptionLevel
