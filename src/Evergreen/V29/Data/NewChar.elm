module Evergreen.V29.Data.NewChar exposing (..)

import Evergreen.V29.Data.Special


type alias NewChar = 
    { special : Evergreen.V29.Data.Special.Special
    , availableSpecial : Int
    }