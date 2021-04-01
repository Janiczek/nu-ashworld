module Evergreen.V45.Data.NewChar exposing (..)

import Evergreen.V45.Data.Special


type alias NewChar = 
    { special : Evergreen.V45.Data.Special.Special
    , availableSpecial : Int
    }