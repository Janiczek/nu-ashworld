module Evergreen.V104.Data.NewChar exposing (..)

import SeqSet
import Evergreen.V104.Data.Skill
import Evergreen.V104.Data.Special
import Evergreen.V104.Data.Trait


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
