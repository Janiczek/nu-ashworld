module Evergreen.V61.Data.Fight exposing (..)

import Evergreen.V61.Data.Fight.ShotType
import Evergreen.V61.Data.Player.PlayerName


type Who
    = Attacker
    | Target


type FightAction
    = Start
        { distanceHexes : Int
        }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , shotType : Evergreen.V61.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V61.Data.Fight.ShotType.ShotType
        }


type FightResult
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


type alias FightInfo =
    { attackerName : Evergreen.V61.Data.Player.PlayerName.PlayerName
    , targetName : Evergreen.V61.Data.Player.PlayerName.PlayerName
    , log : List ( Who, FightAction )
    , result : FightResult
    }
