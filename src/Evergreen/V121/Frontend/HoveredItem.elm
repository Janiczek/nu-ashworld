module Evergreen.V121.Frontend.HoveredItem exposing (..)

import Evergreen.V121.Data.FightStrategy.Help
import Evergreen.V121.Data.Perk
import Evergreen.V121.Data.Skill
import Evergreen.V121.Data.Special
import Evergreen.V121.Data.Special.Perception
import Evergreen.V121.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V121.Data.Perk.Perk
    | HoveredTrait Evergreen.V121.Data.Trait.Trait
    | HoveredSpecial Evergreen.V121.Data.Special.Type
    | HoveredSkill Evergreen.V121.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V121.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V121.Data.Special.Perception.PerceptionLevel
