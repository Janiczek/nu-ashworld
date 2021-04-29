module Evergreen.V81.Data.NewChar exposing (..)

import AssocSet
import Evergreen.V81.Data.Skill
import Evergreen.V81.Data.Special
import Evergreen.V81.Data.Trait


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V81.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : AssocSet.Set Evergreen.V81.Data.Skill.Skill
    , traits : AssocSet.Set Evergreen.V81.Data.Trait.Trait
    , error : Maybe CreationError
    }
