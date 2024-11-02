module Evergreen.V119.Data.NewChar exposing (..)

import Evergreen.V119.Data.Skill
import Evergreen.V119.Data.Special
import Evergreen.V119.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V119.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V119.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V119.Data.Trait.Trait
    , error : Maybe CreationError
    }
