module Evergreen.V97.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V97.Data.Skill
import Evergreen.V97.Data.Special
import Evergreen.V97.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V97.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V97.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V97.Data.Trait.Trait
    , error : Maybe CreationError
    }
