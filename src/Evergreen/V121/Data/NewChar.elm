module Evergreen.V121.Data.NewChar exposing (..)

import Evergreen.V121.Data.Skill
import Evergreen.V121.Data.Special
import Evergreen.V121.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V121.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V121.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V121.Data.Trait.Trait
    , error : Maybe CreationError
    }
