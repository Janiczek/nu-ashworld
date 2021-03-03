module Evergreen.V19.Data.NewChar exposing (..)

import Evergreen.V19.Data.Special as Special exposing (Special)


type alias NewChar =
    { special : Special
    , availableSpecial : Int
    }


init : NewChar
init =
    { special = Special.init
    , availableSpecial = 5
    }
