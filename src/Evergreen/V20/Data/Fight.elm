module Evergreen.V20.Data.Fight exposing (..)

import Evergreen.V20.Data.Player


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


type alias FightInfo = 
    { attacker : Evergreen.V20.Data.Player.PlayerName
    , target : Evergreen.V20.Data.Player.PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }