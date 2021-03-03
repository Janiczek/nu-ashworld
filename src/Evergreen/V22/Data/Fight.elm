module Evergreen.V22.Data.Fight exposing (..)

import Evergreen.V22.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V22.Data.Player.PlayerName
    , target : Evergreen.V22.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }