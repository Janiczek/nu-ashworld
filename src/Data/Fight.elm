module Data.Fight exposing
    ( FightAction(..)
    , FightInfo
    , FightResult(..)
    , Who(..)
    , generator
    , targetAlreadyDead
    )

import Data.Perk as Perk
import Data.Player as Player exposing (PlayerName, SPlayer)
import Data.Special exposing (Special)
import Logic
import Random exposing (Generator)
import Random.Extra as Random


type alias FightInfo =
    { attacker : PlayerName
    , target : PlayerName
    , log : List ( Who, FightAction )
    , result : FightResult
    }


type FightResult
    = AttackerWon { xpGained : Int, capsGained : Int }
    | TargetWon { xpGained : Int, capsGained : Int }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


type Who
    = Attacker
    | Target


type FightAction
    = -- TODO later Reload, WalkAway, uncousciousness and other debuffs...
      Start { distanceHexes : Int }
    | ComeCloser { hexes : Int }
    | Attack { damage : Int }


type alias OngoingFight =
    { attackerHp : Int
    , targetHp : Int
    , reverseLog : List ( Who, FightAction )
    }


generator :
    { attacker : SPlayer
    , target : SPlayer
    }
    -> Generator FightInfo
generator { attacker, target } =
    let
        -- TODO for unarmed attacks check that the range is 1? distance = 0?
        -- TODO for non-unarmed attacks check that the range is <= weapon's range
        startingDistance : Int
        startingDistance =
            -- TODO vary this? based on the Perception / perks / Outdoorsman / ...?
            15

        initialFight : OngoingFight
        initialFight =
            { attackerHp = attacker.hp
            , targetHp = target.hp
            , reverseLog = [ ( Attacker, Start { distanceHexes = startingDistance } ) ]
            }

        sequenceOrder : List Who
        sequenceOrder =
            [ ( Attacker, attacker )
            , ( Target, target )
            ]
                |> List.sortBy
                    (\( _, player ) ->
                        negate <|
                            Logic.sequence
                                { perception = player.special.perception
                                , hasKamikazePerk = Player.perkCount Perk.Kamikaze player > 0
                                , earlierSequencePerkCount = Player.perkCount Perk.EarlierSequence player
                                }
                    )
                |> List.map Tuple.first

        turn : Who -> OngoingFight -> Generator OngoingFight
        turn who ongoing =
            Debug.todo "turn"

        turnsBySequenceLoop : OngoingFight -> Generator OngoingFight
        turnsBySequenceLoop ongoing =
            ongoing
                |> ifBothAlive
                    (\ongoing_ ->
                        turnsBySequence sequenceOrder ongoing_
                            |> Random.andThen turnsBySequenceLoop
                    )

        turnsBySequence : List Who -> OngoingFight -> Generator OngoingFight
        turnsBySequence remaining ongoing =
            ongoing
                |> ifBothAlive
                    (\ongoing_ ->
                        case remaining of
                            [] ->
                                Random.constant ongoing_

                            current :: rest ->
                                turn current ongoing_
                                    |> Random.andThen (turnsBySequence rest)
                    )

        ifBothAlive : (OngoingFight -> Generator OngoingFight) -> OngoingFight -> Generator OngoingFight
        ifBothAlive fn ongoing =
            if ongoing.attackerHp > 0 && ongoing.targetHp > 0 then
                fn ongoing

            else
                Random.constant ongoing

        finalizeFight : OngoingFight -> FightInfo
        finalizeFight ongoing =
            { attacker = attacker.name
            , target = target.name
            , log = List.reverse ongoing.reverseLog
            , result =
                if ongoing.attackerHp <= 0 && ongoing.targetHp <= 0 then
                    BothDead

                else if ongoing.attackerHp <= 0 then
                    TargetWon
                        { capsGained = Debug.todo "target won gained caps"
                        , xpGained = Debug.todo "target won gained xp"
                        }

                else if ongoing.targetHp <= 0 then
                    AttackerWon
                        { capsGained = Debug.todo "attacker won gained caps"
                        , xpGained = Debug.todo "attacker won gained xp"
                        }

                else
                    NobodyDead
            }

        -- AP costs:
        -- movement takes 1 AP per hex
        -- based on various factors attacks take ~5 AP
    in
    initialFight
        |> turn Attacker
        |> Random.andThen (ifBothAlive (turn Target))
        |> Random.andThen turnsBySequenceLoop
        |> Random.map finalizeFight


targetAlreadyDead :
    { attacker : PlayerName
    , target : PlayerName
    }
    -> FightInfo
targetAlreadyDead { attacker, target } =
    { attacker = attacker
    , target = target
    , log = []
    , result = TargetAlreadyDead
    }
