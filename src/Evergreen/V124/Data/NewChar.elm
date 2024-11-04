module Evergreen.V124.Data.NewChar exposing (..)

import Evergreen.V124.Data.Skill
import Evergreen.V124.Data.Special
import Evergreen.V124.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V124.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V124.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V124.Data.Trait.Trait
    , error : Maybe CreationError
    }
