module Evergreen.V114.Frontend.HoveredItem exposing (..)

import Evergreen.V114.Data.FightStrategy.Help
import Evergreen.V114.Data.Perk
import Evergreen.V114.Data.Skill
import Evergreen.V114.Data.Special
import Evergreen.V114.Data.Special.Perception
import Evergreen.V114.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V114.Data.Perk.Perk
    | HoveredTrait Evergreen.V114.Data.Trait.Trait
    | HoveredSpecial Evergreen.V114.Data.Special.Type
    | HoveredSkill Evergreen.V114.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V114.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V114.Data.Special.Perception.PerceptionLevel
