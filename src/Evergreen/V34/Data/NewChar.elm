module Evergreen.V34.Data.NewChar exposing (..)

import Evergreen.V34.Data.Special


type alias NewChar = 
    { special : Evergreen.V34.Data.Special.Special
    , availableSpecial : Int
    }