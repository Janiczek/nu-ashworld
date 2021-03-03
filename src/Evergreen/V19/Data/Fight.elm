module Evergreen.V19.Data.Fight exposing (..)

import Evergreen.V19.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V19.Data.Player.PlayerName
    , target : Evergreen.V19.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }