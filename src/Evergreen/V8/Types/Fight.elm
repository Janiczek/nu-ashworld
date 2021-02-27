module Evergreen.V8.Types.Fight exposing (..)

import Evergreen.V8.Types.Player


type FightResult
    = AttackerWon
    | TargetWon


type alias FightInfo = 
    { attacker : Evergreen.V8.Types.Player.PlayerName
    , target : Evergreen.V8.Types.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }