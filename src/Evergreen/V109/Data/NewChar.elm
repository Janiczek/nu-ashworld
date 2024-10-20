module Evergreen.V109.Data.NewChar exposing (..)

import Evergreen.V109.Data.Skill
import Evergreen.V109.Data.Special
import Evergreen.V109.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V109.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V109.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V109.Data.Trait.Trait
    , error : Maybe CreationError
    }
