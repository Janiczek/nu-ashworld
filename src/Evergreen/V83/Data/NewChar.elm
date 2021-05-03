module Evergreen.V83.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V83.Data.Skill
import Evergreen.V83.Data.Special
import Evergreen.V83.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V83.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V83.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V83.Data.Trait.Trait
    , error : Maybe CreationError
    }
