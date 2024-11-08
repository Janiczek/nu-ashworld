module Evergreen.V135.Data.NewChar exposing (..)

import Evergreen.V135.Data.Skill
import Evergreen.V135.Data.Special
import Evergreen.V135.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V135.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V135.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V135.Data.Trait.Trait
    , error : Maybe CreationError
    }
