module Evergreen.V104.Data.NewChar exposing (..)

import Evergreen.V104.Data.Skill
import Evergreen.V104.Data.Special
import Evergreen.V104.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V104.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V104.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V104.Data.Trait.Trait
    , error : Maybe CreationError
    }
