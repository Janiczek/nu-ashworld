module Evergreen.V89.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V89.Data.Skill
import Evergreen.V89.Data.Special
import Evergreen.V89.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V89.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V89.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V89.Data.Trait.Trait
    , error : Maybe CreationError
    }
