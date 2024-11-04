module Evergreen.V125.Data.NewChar exposing (..)

import Evergreen.V125.Data.Skill
import Evergreen.V125.Data.Special
import Evergreen.V125.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V125.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V125.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V125.Data.Trait.Trait
    , error : Maybe CreationError
    }
