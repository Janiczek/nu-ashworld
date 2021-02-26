module Evergreen.V3.Types.Player exposing (..)

import Evergreen.V3.Types.Special
import Evergreen.V3.Types.Xp


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V3.Types.Xp.Level
    , name : String
    , wins : Int
    , losses : Int
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V3.Types.Xp.Xp
    , name : String
    , special : Evergreen.V3.Types.Special.Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias SPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : String
    , special : Evergreen.V3.Types.Special.Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }