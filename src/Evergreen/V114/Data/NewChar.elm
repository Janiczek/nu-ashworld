module Evergreen.V114.Data.NewChar exposing (..)

import Evergreen.V114.Data.Skill
import Evergreen.V114.Data.Special
import Evergreen.V114.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V114.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V114.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V114.Data.Trait.Trait
    , error : Maybe CreationError
    }
