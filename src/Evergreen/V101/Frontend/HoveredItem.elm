module Evergreen.V101.Frontend.HoveredItem exposing (..)

import Evergreen.V101.Data.Perk
import Evergreen.V101.Data.Skill
import Evergreen.V101.Data.Special
import Evergreen.V101.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V101.Data.Perk.Perk
    | HoveredTrait Evergreen.V101.Data.Trait.Trait
    | HoveredSpecial Evergreen.V101.Data.Special.Type
    | HoveredSkill Evergreen.V101.Data.Skill.Skill
