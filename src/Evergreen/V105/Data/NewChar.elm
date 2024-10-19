module Evergreen.V105.Data.NewChar exposing (..)

import Evergreen.V105.Data.Skill
import Evergreen.V105.Data.Special
import Evergreen.V105.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V105.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V105.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V105.Data.Trait.Trait
    , error : Maybe CreationError
    }
