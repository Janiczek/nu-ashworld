module Evergreen.V68.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V68.Data.Skill
import Evergreen.V68.Data.Special
import Evergreen.V68.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V68.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V68.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V68.Data.Trait.Trait
    , error : Maybe CreationError
    }
