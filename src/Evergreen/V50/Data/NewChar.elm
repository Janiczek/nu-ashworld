module Evergreen.V50.Data.NewChar exposing (..)

import Evergreen.V50.Data.Special


type alias NewChar = 
    { special : Evergreen.V50.Data.Special.Special
    , availableSpecial : Int
    }