module Evergreen.V27.Data.NewChar exposing (..)

import Evergreen.V27.Data.Special


type alias NewChar = 
    { special : Evergreen.V27.Data.Special.Special
    , availableSpecial : Int
    }