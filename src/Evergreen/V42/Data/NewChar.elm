module Evergreen.V42.Data.NewChar exposing (..)

import Evergreen.V42.Data.Special


type alias NewChar = 
    { special : Evergreen.V42.Data.Special.Special
    , availableSpecial : Int
    }