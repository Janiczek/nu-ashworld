module Evergreen.V132.Data.NewChar exposing (..)

import Evergreen.V132.Data.Skill
import Evergreen.V132.Data.Special
import Evergreen.V132.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V132.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V132.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V132.Data.Trait.Trait
    , error : Maybe CreationError
    }
