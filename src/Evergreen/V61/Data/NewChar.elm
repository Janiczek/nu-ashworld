module Evergreen.V61.Data.NewChar exposing (..)

import Evergreen.V61.Data.Special


type alias NewChar =
    { special : Evergreen.V61.Data.Special.Special
    , availableSpecial : Int
    }
