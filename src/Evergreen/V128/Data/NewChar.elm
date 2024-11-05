module Evergreen.V128.Data.NewChar exposing (..)

import Evergreen.V128.Data.Skill
import Evergreen.V128.Data.Special
import Evergreen.V128.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V128.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V128.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V128.Data.Trait.Trait
    , error : Maybe CreationError
    }
