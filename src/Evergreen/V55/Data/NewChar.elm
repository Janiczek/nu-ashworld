module Evergreen.V55.Data.NewChar exposing (..)

import Evergreen.V55.Data.Special


type alias NewChar = 
    { special : Evergreen.V55.Data.Special.Special
    , availableSpecial : Int
    }