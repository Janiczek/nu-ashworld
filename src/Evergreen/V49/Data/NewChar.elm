module Evergreen.V49.Data.NewChar exposing (..)

import Evergreen.V49.Data.Special


type alias NewChar = 
    { special : Evergreen.V49.Data.Special.Special
    , availableSpecial : Int
    }