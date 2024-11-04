module Evergreen.V124.Frontend.HoveredItem exposing (..)

import Evergreen.V124.Data.FightStrategy.Help
import Evergreen.V124.Data.Perk
import Evergreen.V124.Data.Skill
import Evergreen.V124.Data.Special
import Evergreen.V124.Data.Special.Perception
import Evergreen.V124.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V124.Data.Perk.Perk
    | HoveredTrait Evergreen.V124.Data.Trait.Trait
    | HoveredSpecial Evergreen.V124.Data.Special.Type
    | HoveredSkill Evergreen.V124.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V124.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V124.Data.Special.Perception.PerceptionLevel
