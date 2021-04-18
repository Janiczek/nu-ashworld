module Evergreen.V66.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V66.Data.Skill
import Evergreen.V66.Data.Special
import Evergreen.V66.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V66.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V66.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V66.Data.Trait.Trait
    , error : Maybe CreationError
    }
