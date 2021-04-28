module Evergreen.V71.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V71.Data.Skill
import Evergreen.V71.Data.Special
import Evergreen.V71.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V71.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V71.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V71.Data.Trait.Trait
    , error : Maybe CreationError
    }
