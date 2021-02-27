module Types.Fight exposing
    ( FightInfo
    , FightResult(..)
    , generator
    )

import Random exposing (Generator)
import Random.Extra as Random
import Types.Player exposing (PlayerName)


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
