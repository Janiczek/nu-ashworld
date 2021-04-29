module Evergreen.V78.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V78.Data.Skill
import Evergreen.V78.Data.Special
import Evergreen.V78.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V78.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V78.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V78.Data.Trait.Trait
    , error : Maybe CreationError
    }
