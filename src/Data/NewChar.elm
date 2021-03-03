module Data.NewChar exposing (NewChar, decSpecial, incSpecial, init)

import Data.Special as Special exposing (Special, SpecialType)


type alias NewChar =
    { special : Special
    , availableSpecial : Int
    }


init : NewChar
init =
    { special = Special.init
    , availableSpecial = 5
    }


incSpecial : SpecialType -> NewChar -> NewChar
incSpecial type_ char =
    if Special.canIncrement char.availableSpecial type_ char.special then
        { char
            | special = Special.increment type_ char.special
            , availableSpecial = char.availableSpecial - 1
        }

    else
        char


decSpecial : SpecialType -> NewChar -> NewChar
decSpecial type_ char =
    if Special.canDecrement type_ char.special then
        { char
            | special = Special.decrement type_ char.special
            , availableSpecial = char.availableSpecial + 1
        }

    else
        char
