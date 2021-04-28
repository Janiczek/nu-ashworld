module Evergreen.V70.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V70.Data.Skill
import Evergreen.V70.Data.Special
import Evergreen.V70.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V70.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V70.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V70.Data.Trait.Trait
    , error : Maybe CreationError
    }
