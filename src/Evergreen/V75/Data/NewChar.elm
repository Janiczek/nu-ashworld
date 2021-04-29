module Evergreen.V75.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V75.Data.Skill
import Evergreen.V75.Data.Special
import Evergreen.V75.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V75.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V75.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V75.Data.Trait.Trait
    , error : Maybe CreationError
    }
