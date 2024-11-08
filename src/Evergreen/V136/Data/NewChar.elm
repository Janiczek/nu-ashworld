module Evergreen.V136.Data.NewChar exposing (..)

import Evergreen.V136.Data.Skill
import Evergreen.V136.Data.Special
import Evergreen.V136.Data.Trait
import SeqSet


type CreationError
    = DoesNotHaveThreeTaggedSkills
    | HasSpecialPointsLeft
    | UsedMoreSpecialPointsThanAvailable
    | HasSpecialOutOfRange
    | HasMoreThanTwoTraits


type alias NewChar =
    { baseSpecial : Evergreen.V136.Data.Special.Special
    , availableSpecial : Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V136.Data.Skill.Skill
    , traits : SeqSet.SeqSet Evergreen.V136.Data.Trait.Trait
    , error : Maybe CreationError
    }
