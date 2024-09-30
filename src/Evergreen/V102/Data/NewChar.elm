module Evergreen.V102.Data.NewChar exposing (..)

import Evergreen.V102.Data.Skill
import Evergreen.V102.Data.Special
import Evergreen.V102.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V102.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V102.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V102.Data.Trait.Trait
    , error : Maybe CreationError
    }
