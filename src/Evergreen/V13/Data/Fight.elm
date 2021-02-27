module Evergreen.V13.Data.Fight exposing (..)

import Evergreen.V13.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V13.Data.Player.PlayerName
    , target : Evergreen.V13.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }