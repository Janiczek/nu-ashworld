module Evergreen.V19.Data.NewChar exposing (..)

import Evergreen.V19.Data.Special


type alias NewChar = 
    { special : Evergreen.V19.Data.Special.Special
    , availableSpecial : Int
    }