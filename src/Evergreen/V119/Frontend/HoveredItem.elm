module Evergreen.V119.Frontend.HoveredItem exposing (..)

import Evergreen.V119.Data.FightStrategy.Help
import Evergreen.V119.Data.Perk
import Evergreen.V119.Data.Skill
import Evergreen.V119.Data.Special
import Evergreen.V119.Data.Special.Perception
import Evergreen.V119.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V119.Data.Perk.Perk
    | HoveredTrait Evergreen.V119.Data.Trait.Trait
    | HoveredSpecial Evergreen.V119.Data.Special.Type
    | HoveredSkill Evergreen.V119.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V119.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V119.Data.Special.Perception.PerceptionLevel
