module Evergreen.V110.Data.NewChar exposing (..)

import Evergreen.V110.Data.Skill
import Evergreen.V110.Data.Special
import Evergreen.V110.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V110.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V110.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V110.Data.Trait.Trait
    , error : Maybe CreationError
    }
