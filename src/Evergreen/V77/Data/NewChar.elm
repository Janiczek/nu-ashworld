module Evergreen.V77.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V77.Data.Skill
import Evergreen.V77.Data.Special
import Evergreen.V77.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V77.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V77.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V77.Data.Trait.Trait
    , error : Maybe CreationError
    }
