module Evergreen.V1.Types.Player exposing (..)

import Evergreen.V1.Types.Special
import Evergreen.V1.Types.Xp


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V1.Types.Xp.Xp
    , name : String
    , special : Evergreen.V1.Types.Special.Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V1.Types.Xp.Level
    , name : String
    , wins : Int
    , losses : Int
    }


type alias SPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : String
    , special : Evergreen.V1.Types.Special.Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }