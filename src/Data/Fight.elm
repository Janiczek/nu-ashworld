module Data.Fight exposing
    ( FightInfo
    , FightResult(..)
    , generator
    , targetAlreadyDead
    )

import Data.Player exposing (PlayerName, SPlayer)
import Random exposing (Generator)
import Random.Extra as Random


type alias FightInfo =
    { attacker : PlayerName
    , target : PlayerName
    , result : FightResult
    , winnerXpGained : Int
    , winnerCapsGained : Int
    }


type FightResult
    = AttackerWon
    | TargetWon
    | TargetAlreadyDead


generator :
    { attacker : SPlayer
    , target : SPlayer
    }
    -> Generator FightInfo
generator { attacker, target } =
    -- TODO this is veeeery simple and stupid, 50:50 chance
    Random.bool
        |> Random.map
            (\attackerWon ->
                if attackerWon then
                    { attacker = attacker.name
                    , target = target.name
                    , result = AttackerWon
                    , winnerXpGained = target.hp
                    , winnerCapsGained = target.caps
                    }

                else
                    { attacker = attacker.name
                    , target = target.name
                    , result = TargetWon
                    , winnerXpGained = attacker.hp
                    , winnerCapsGained = attacker.caps
                    }
            )


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
