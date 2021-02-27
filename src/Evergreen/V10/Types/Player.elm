module Evergreen.V10.Types.Player exposing (..)

import Evergreen.V10.Types.Special
import Evergreen.V10.Types.Xp


type alias PlayerName = String


type alias COtherPlayer = 
    { hp : Int
    , level : Evergreen.V10.Types.Xp.Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    }


type alias CPlayer = 
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V10.Types.Xp.Xp
    , name : PlayerName
    , special : Evergreen.V10.Types.Special.Special
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
    , special : Evergreen.V10.Types.Special.Special
    , availableSpecial : Int
    , caps : Int
    , ap : Int
    , wins : Int
    , losses : Int
    }