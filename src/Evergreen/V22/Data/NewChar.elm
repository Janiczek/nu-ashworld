module Evergreen.V22.Data.NewChar exposing (..)

import Evergreen.V22.Data.Special


type alias NewChar = 
    { special : Evergreen.V22.Data.Special.Special
    , availableSpecial : Int
    }