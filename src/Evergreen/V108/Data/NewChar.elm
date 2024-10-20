module Evergreen.V108.Data.NewChar exposing (..)

import Evergreen.V108.Data.Skill
import Evergreen.V108.Data.Special
import Evergreen.V108.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V108.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V108.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V108.Data.Trait.Trait
    , error : Maybe CreationError
    }
