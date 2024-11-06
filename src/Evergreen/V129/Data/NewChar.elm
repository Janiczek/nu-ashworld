module Evergreen.V129.Data.NewChar exposing (..)

import Evergreen.V129.Data.Skill
import Evergreen.V129.Data.Special
import Evergreen.V129.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V129.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V129.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V129.Data.Trait.Trait
    , error : Maybe CreationError
    }
