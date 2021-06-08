module Evergreen.V97.Frontend.HoveredItem exposing (..)

import Evergreen.V97.Data.Perk
import Evergreen.V97.Data.Skill
import Evergreen.V97.Data.Special
import Evergreen.V97.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V97.Data.Perk.Perk
    | HoveredTrait Evergreen.V97.Data.Trait.Trait
    | HoveredSpecial Evergreen.V97.Data.Special.Type
    | HoveredSkill Evergreen.V97.Data.Skill.Skill
