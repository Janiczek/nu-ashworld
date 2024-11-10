module Evergreen.V137.Data.NewChar exposing (..)

import Evergreen.V137.Data.Skill
import Evergreen.V137.Data.Special
import Evergreen.V137.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V137.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V137.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V137.Data.Trait.Trait
    , error : Maybe CreationError
    }
