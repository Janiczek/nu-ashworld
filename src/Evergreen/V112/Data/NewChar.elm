module Evergreen.V112.Data.NewChar exposing (..)

import Evergreen.V112.Data.Skill
import Evergreen.V112.Data.Special
import Evergreen.V112.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V112.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V112.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V112.Data.Trait.Trait
    , error : Maybe CreationError
    }
