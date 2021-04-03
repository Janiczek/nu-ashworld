module Evergreen.V59.Data.NewChar exposing (..)

import Evergreen.V59.Data.Special


type alias NewChar = 
    { special : Evergreen.V59.Data.Special.Special
    , availableSpecial : Int
    }