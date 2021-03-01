module Evergreen.V17.Data.Fight exposing (..)

import Evergreen.V17.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V17.Data.Player.PlayerName
    , target : Evergreen.V17.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }