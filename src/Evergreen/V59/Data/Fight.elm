module Evergreen.V59.Data.Fight exposing (..)

import Evergreen.V59.Data.Fight.ShotType
import Evergreen.V59.Data.Player.PlayerName


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
    , shotType : Evergreen.V59.Data.Fight.ShotType.ShotType
    , remainingHp : Int
    }
    | Miss 
    { shotType : Evergreen.V59.Data.Fight.ShotType.ShotType
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
    { attackerName : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , targetName : Evergreen.V59.Data.Player.PlayerName.PlayerName
    , log : (List (Who, FightAction))
    , result : FightResult
    }