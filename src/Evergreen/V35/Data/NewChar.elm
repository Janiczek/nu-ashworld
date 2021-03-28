module Evergreen.V35.Data.NewChar exposing (..)

import Evergreen.V35.Data.Special


type alias NewChar = 
    { special : Evergreen.V35.Data.Special.Special
    , availableSpecial : Int
    }