module Evergreen.V100.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V100.Data.Skill
import Evergreen.V100.Data.Special
import Evergreen.V100.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V100.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V100.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V100.Data.Trait.Trait
    , error : Maybe CreationError
    }
