module Evergreen.V96.Frontend.HoveredItem exposing (..)

import Evergreen.V96.Data.Perk
import Evergreen.V96.Data.Skill
import Evergreen.V96.Data.Special
import Evergreen.V96.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V96.Data.Perk.Perk
    | HoveredTrait Evergreen.V96.Data.Trait.Trait
    | HoveredSpecial Evergreen.V96.Data.Special.Type
    | HoveredSkill Evergreen.V96.Data.Skill.Skill
