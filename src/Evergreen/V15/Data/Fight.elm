module Evergreen.V15.Data.Fight exposing (..)

import Evergreen.V15.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V15.Data.Player.PlayerName
    , target : Evergreen.V15.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }