module Evergreen.V10.Types.Fight exposing (..)

import Evergreen.V10.Types.Player


type FightResult
    = AttackerWon
    | TargetWon


type alias FightInfo = 
    { attacker : Evergreen.V10.Types.Player.PlayerName
    , target : Evergreen.V10.Types.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }