module Evergreen.V58.Data.NewChar exposing (..)

import Evergreen.V58.Data.Special


type alias NewChar = 
    { special : Evergreen.V58.Data.Special.Special
    , availableSpecial : Int
    }