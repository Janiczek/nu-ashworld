module Evergreen.V120.Frontend.HoveredItem exposing (..)

import Evergreen.V120.Data.FightStrategy.Help
import Evergreen.V120.Data.Perk
import Evergreen.V120.Data.Skill
import Evergreen.V120.Data.Special
import Evergreen.V120.Data.Special.Perception
import Evergreen.V120.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V120.Data.Perk.Perk
    | HoveredTrait Evergreen.V120.Data.Trait.Trait
    | HoveredSpecial Evergreen.V120.Data.Special.Type
    | HoveredSkill Evergreen.V120.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V120.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V120.Data.Special.Perception.PerceptionLevel
