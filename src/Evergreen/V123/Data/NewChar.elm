module Evergreen.V123.Data.NewChar exposing (..)

import Evergreen.V123.Data.Skill
import Evergreen.V123.Data.Special
import Evergreen.V123.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V123.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V123.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V123.Data.Trait.Trait
    , error : Maybe CreationError
    }
