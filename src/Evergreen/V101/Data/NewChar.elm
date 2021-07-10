module Evergreen.V101.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V101.Data.Skill
import Evergreen.V101.Data.Special
import Evergreen.V101.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V101.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V101.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V101.Data.Trait.Trait
    , error : Maybe CreationError
    }
