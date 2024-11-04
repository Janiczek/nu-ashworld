module Evergreen.V123.Frontend.HoveredItem exposing (..)

import Evergreen.V123.Data.FightStrategy.Help
import Evergreen.V123.Data.Perk
import Evergreen.V123.Data.Skill
import Evergreen.V123.Data.Special
import Evergreen.V123.Data.Special.Perception
import Evergreen.V123.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V123.Data.Perk.Perk
    | HoveredTrait Evergreen.V123.Data.Trait.Trait
    | HoveredSpecial Evergreen.V123.Data.Special.Type
    | HoveredSkill Evergreen.V123.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V123.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V123.Data.Special.Perception.PerceptionLevel
