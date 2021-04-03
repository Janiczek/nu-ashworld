module Evergreen.V58.Data.Fight exposing (..)

import Evergreen.V58.Data.Fight.ShotType
import Evergreen.V58.Data.Player


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
    , shotType : Evergreen.V58.Data.Fight.ShotType.ShotType
    , remainingHp : Int
    }
    | Miss 
    { shotType : Evergreen.V58.Data.Fight.ShotType.ShotType
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
    { attacker : Evergreen.V58.Data.Player.SPlayer
    , target : Evergreen.V58.Data.Player.SPlayer
    , log : (List (Who, FightAction))
    , result : FightResult
    }