module Evergreen.V12.Data.Fight exposing (..)

import Evergreen.V12.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V12.Data.Player.PlayerName
    , target : Evergreen.V12.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }