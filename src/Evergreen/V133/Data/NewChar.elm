module Evergreen.V133.Data.NewChar exposing (..)

import Evergreen.V133.Data.Skill
import Evergreen.V133.Data.Special
import Evergreen.V133.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V133.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V133.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V133.Data.Trait.Trait
    , error : Maybe CreationError
    }
