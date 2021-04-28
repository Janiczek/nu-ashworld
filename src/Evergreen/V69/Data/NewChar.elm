module Evergreen.V69.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V69.Data.Skill
import Evergreen.V69.Data.Special
import Evergreen.V69.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V69.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V69.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V69.Data.Trait.Trait
    , error : Maybe CreationError
    }
