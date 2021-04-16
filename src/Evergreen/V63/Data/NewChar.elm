module Evergreen.V63.Data.NewChar exposing (..)

import Evergreen.V63.Data.Special


type alias NewChar =
    { special : Evergreen.V63.Data.Special.Special
    , availableSpecial : Int
    }
