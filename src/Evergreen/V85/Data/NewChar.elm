module Evergreen.V85.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V85.Data.Skill
import Evergreen.V85.Data.Special
import Evergreen.V85.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V85.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V85.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V85.Data.Trait.Trait
    , error : Maybe CreationError
    }
