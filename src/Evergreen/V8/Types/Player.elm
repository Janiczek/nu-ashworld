module Evergreen.V8.Types.Player exposing (..)

import Evergreen.V8.Types.Special
import Evergreen.V8.Types.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V8.Types.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V8.Types.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V8.Types.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }


type alias SPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Int
    , name : PlayerName
    , special : Evergreen.V8.Types.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }