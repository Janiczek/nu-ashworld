module Evergreen.V29.Data.Fight exposing (..)

import Evergreen.V29.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V29.Data.Player.PlayerName
    , target : Evergreen.V29.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }