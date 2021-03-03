module Evergreen.V20.Data.NewChar exposing (..)

import Evergreen.V20.Data.Special


type alias NewChar = 
    { special : Evergreen.V20.Data.Special.Special
    , availableSpecial : Int
    }