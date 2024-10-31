module Evergreen.V118.Data.NewChar exposing (..)

import Evergreen.V118.Data.Skill
import Evergreen.V118.Data.Special
import Evergreen.V118.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V118.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V118.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V118.Data.Trait.Trait
    , error : Maybe CreationError
    }
