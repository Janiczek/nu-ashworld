module Evergreen.V37.Data.NewChar exposing (..)

import Evergreen.V37.Data.Special


type alias NewChar = 
    { special : Evergreen.V37.Data.Special.Special
    , availableSpecial : Int
    }