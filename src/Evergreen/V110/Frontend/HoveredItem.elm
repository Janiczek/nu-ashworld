module Evergreen.V110.Frontend.HoveredItem exposing (..)

import Evergreen.V110.Data.FightStrategy.Help
import Evergreen.V110.Data.Perk
import Evergreen.V110.Data.Skill
import Evergreen.V110.Data.Special
import Evergreen.V110.Data.Special.Perception
import Evergreen.V110.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V110.Data.Perk.Perk
    | HoveredTrait Evergreen.V110.Data.Trait.Trait
    | HoveredSpecial Evergreen.V110.Data.Special.Type
    | HoveredSkill Evergreen.V110.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V110.Data.FightStrategy.Help.Reference
    | HoveredPerceptionLevel Evergreen.V110.Data.Special.Perception.PerceptionLevel
