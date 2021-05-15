module Evergreen.V88.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V88.Data.Skill
import Evergreen.V88.Data.Special
import Evergreen.V88.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V88.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V88.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V88.Data.Trait.Trait
    , error : Maybe CreationError
    }
