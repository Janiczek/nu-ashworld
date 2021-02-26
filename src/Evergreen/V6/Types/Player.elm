module Evergreen.V6.Types.Player exposing (..)

import Evergreen.V6.Types.Special
import Evergreen.V6.Types.Xp


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V6.Types.Xp.Level
    , name : String
    , wins : Int
    , losses : Int
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V6.Types.Xp.Xp
    , name : String
    , special : Evergreen.V6.Types.Special.Special
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
    , special : Evergreen.V6.Types.Special.Special
    , availableSpecial : Int
    , cash : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }