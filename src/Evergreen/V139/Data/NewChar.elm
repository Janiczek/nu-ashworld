module Evergreen.V139.Data.NewChar exposing (..)

import Evergreen.V139.Data.Skill
import Evergreen.V139.Data.Special
import Evergreen.V139.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V139.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V139.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V139.Data.Trait.Trait
    , error : Maybe CreationError
    }
