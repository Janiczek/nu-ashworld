module Evergreen.V96.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V96.Data.Skill
import Evergreen.V96.Data.Special
import Evergreen.V96.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V96.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V96.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V96.Data.Trait.Trait
    , error : Maybe CreationError
    }
