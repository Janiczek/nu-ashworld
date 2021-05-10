module Evergreen.V87.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V87.Data.Skill
import Evergreen.V87.Data.Special
import Evergreen.V87.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V87.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V87.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V87.Data.Trait.Trait
    , error : Maybe CreationError
    }
