module Evergreen.V16.Data.Fight exposing (..)

import Evergreen.V16.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V16.Data.Player.PlayerName
    , target : Evergreen.V16.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }