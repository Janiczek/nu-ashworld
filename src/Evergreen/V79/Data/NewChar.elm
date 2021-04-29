module Evergreen.V79.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V79.Data.Skill
import Evergreen.V79.Data.Special
import Evergreen.V79.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V79.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V79.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V79.Data.Trait.Trait
    , error : Maybe CreationError
    }
