module Evergreen.V27.Data.Fight exposing (..)

import Evergreen.V27.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V27.Data.Player.PlayerName
    , target : Evergreen.V27.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }