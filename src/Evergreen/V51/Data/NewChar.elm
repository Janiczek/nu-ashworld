module Evergreen.V51.Data.NewChar exposing (..)

import Evergreen.V51.Data.Special


type alias NewChar = 
    { special : Evergreen.V51.Data.Special.Special
    , availableSpecial : Int
    }