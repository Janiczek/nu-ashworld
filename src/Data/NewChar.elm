module Data.NewChar exposing (NewChar, init)

import Data.Special as Special exposing (Special)


type alias NewChar =
    { special : Special
    , availableSpecial : Int
    }


init : NewChar
init =
    { special = Special.init
    , availableSpecial = 5
    }
