module Evergreen.V104.Frontend.HoveredItem exposing (..)

import Evergreen.V104.Data.FightStrategy.Help
import Evergreen.V104.Data.Perk
import Evergreen.V104.Data.Skill
import Evergreen.V104.Data.Special
import Evergreen.V104.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V104.Data.Perk.Perk
    | HoveredTrait Evergreen.V104.Data.Trait.Trait
    | HoveredSpecial Evergreen.V104.Data.Special.Type
    | HoveredSkill Evergreen.V104.Data.Skill.Skill
    | HoveredFightStrategyReference Evergreen.V104.Data.FightStrategy.Help.Reference
