module Evergreen.V62.Data.NewChar exposing (..)

import Evergreen.V62.Data.Special


type alias NewChar =
    { special : Evergreen.V62.Data.Special.Special
    , availableSpecial : Int
    }
