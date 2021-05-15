module Evergreen.V89.Frontend.HoveredItem exposing (..)

import Evergreen.V89.Data.Perk
import Evergreen.V89.Data.Skill
import Evergreen.V89.Data.Special
import Evergreen.V89.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V89.Data.Perk.Perk
    | HoveredTrait Evergreen.V89.Data.Trait.Trait
    | HoveredSpecial Evergreen.V89.Data.Special.Type
    | HoveredSkill Evergreen.V89.Data.Skill.Skill
