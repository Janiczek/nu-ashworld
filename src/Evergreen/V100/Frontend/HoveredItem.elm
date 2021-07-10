module Evergreen.V100.Frontend.HoveredItem exposing (..)

import Evergreen.V100.Data.Perk
import Evergreen.V100.Data.Skill
import Evergreen.V100.Data.Special
import Evergreen.V100.Data.Trait


type HoveredItem
    = HoveredPerk Evergreen.V100.Data.Perk.Perk
    | HoveredTrait Evergreen.V100.Data.Trait.Trait
    | HoveredSpecial Evergreen.V100.Data.Special.Type
    | HoveredSkill Evergreen.V100.Data.Skill.Skill
