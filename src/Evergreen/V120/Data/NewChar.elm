module Evergreen.V120.Data.NewChar exposing (..)

import Evergreen.V120.Data.Skill
import Evergreen.V120.Data.Special
import Evergreen.V120.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V120.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V120.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V120.Data.Trait.Trait
    , error : Maybe CreationError
    }
