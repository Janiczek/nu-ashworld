module Data.Fight exposing
    ( FightInfo
    , FightResult(..)
    , generator
    , targetAlreadyDead
    )

import Data.Player exposing (PlayerName)
import Random exposing (Generator)
import Random.Extra as Random


type alias FightInfo =
    { attacker : PlayerName
    , target : PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int -- TODO do we want to keep this?
    }


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


generator :
    { attacker : PlayerName
    , target : PlayerName
    }
    -> Generator FightInfo
generator { attacker, target } =
    -- TODO this is veeeery simple and stupid
    Random.constant (FightInfo attacker target)
        |> Random.andMap (Random.uniform AttackerWon [ TargetWon ])
        |> Random.andMap (Random.int 1 100)
        |> Random.andMap (Random.int 1 100)


targetAlreadyDead :
    { attacker : PlayerName
    , target : PlayerName
    }
    -> FightInfo
targetAlreadyDead { attacker, target } =
    { attacker = attacker
    , target = target
    , result = TargetAlreadyDead
    , winnerXpGained = 0
    , winnerCapsGained = 0
    }
