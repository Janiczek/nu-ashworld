module Data.Fight exposing
    ( FightAction(..)
    , FightInfo
    , FightResult(..)
    , Who(..)
    , generator
    , targetAlreadyDead
    )

import Data.Fight.ShotType as ShotType exposing (ShotType(..))
import Data.Perk as Perk
import Data.Player as Player exposing (PlayerName, SPlayer)
import Data.Player.SPlayer as SPlayer
import Data.Special exposing (Special)
import Logic
import Random exposing (Generator)
import Random.Extra as Random


type alias FightInfo =
    { attacker : SPlayer
    , target : SPlayer
    , log : List ( Who, FightAction )
    , result : FightResult
    }


{-| These are only for presentation purposes, at the time of construction they
have already been udpated in the SPlayer.
-}
type FightResult
    = AttackerWon { xpGained : Int, capsGained : Int }
    | TargetWon { xpGained : Int, capsGained : Int }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


type Who
    = Attacker
    | Target


theOther : Who -> Who
theOther who =
    case who of
        Attacker ->
            Target

        Target ->
            Attacker


type FightAction
    = -- TODO later Reload, Heal, WalkAway, uncousciousness and other debuffs...
      Start { distanceHexes : Int }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , shotType : ShotType
        , remainingHp : Int
        }


type alias OngoingFight =
    { distanceHexes : Int
    , attacker : SPlayer
    , target : SPlayer
    , attackerAp : Int
    , targetAp : Int
    , reverseLog : List ( Who, FightAction )
    }


generator :
    { attacker : SPlayer
    , target : SPlayer
    }
    -> Generator FightInfo
generator initPlayers =
    let
        -- TODO for non-unarmed attacks check that the range is <= weapon's range
        startingDistance : Generator Int
        startingDistance =
            -- TODO vary this based on the Perception / perks / Outdoorsman / ...?
            Random.int 10 20

        attackerMaxAp : Int
        attackerMaxAp =
            Logic.actionPoints initPlayers.attacker.special

        targetMaxAp : Int
        targetMaxAp =
            Logic.actionPoints initPlayers.target.special

        initialFight : Generator OngoingFight
        initialFight =
            startingDistance
                |> Random.map
                    (\distance ->
                        { distanceHexes = distance
                        , attacker = initPlayers.attacker
                        , target = initPlayers.target
                        , attackerAp = attackerMaxAp
                        , targetAp = targetMaxAp
                        , reverseLog = [ ( Attacker, Start { distanceHexes = distance } ) ]
                        }
                    )

        sequenceOrder : List Who
        sequenceOrder =
            [ ( Attacker, initPlayers.attacker )
            , ( Target, initPlayers.target )
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
            ongoing
                |> resetAp who
                |> Random.constant
                |> Random.andThen (comeCloser who)
                |> Random.andThen (attackWhilePossible who)

        resetAp : Who -> OngoingFight -> OngoingFight
        resetAp who ongoing =
            case who of
                Attacker ->
                    { ongoing | attackerAp = attackerMaxAp }

                Target ->
                    { ongoing | targetAp = targetMaxAp }

        attackWhilePossible : Who -> OngoingFight -> Generator OngoingFight
        attackWhilePossible who ongoing =
            let
                myHp =
                    player_ who ongoing |> .hp

                otherHp =
                    player_ (theOther who) ongoing |> .hp

                minApCost =
                    attackApCost { isAimedShot = False }
            in
            if playerAp who ongoing >= minApCost && otherHp > 0 && myHp > 0 then
                Random.constant ongoing
                    |> Random.andThen (attack who)
                    |> Random.andThen (attackWhilePossible who)

            else
                Random.constant ongoing

        player_ : Who -> OngoingFight -> SPlayer
        player_ who ongoing =
            case who of
                Attacker ->
                    ongoing.attacker

                Target ->
                    ongoing.target

        playerAp : Who -> OngoingFight -> Int
        playerAp who ongoing =
            case who of
                Attacker ->
                    ongoing.attackerAp

                Target ->
                    ongoing.targetAp

        addLog : Who -> FightAction -> OngoingFight -> OngoingFight
        addLog who action ongoing =
            { ongoing | reverseLog = ( who, action ) :: ongoing.reverseLog }

        subtractAp : Who -> Int -> OngoingFight -> OngoingFight
        subtractAp who apToSubtract ongoing =
            case who of
                Attacker ->
                    { ongoing | attackerAp = ongoing.attackerAp - apToSubtract }

                Target ->
                    { ongoing | targetAp = ongoing.targetAp - apToSubtract }

        baseApCost : Int
        baseApCost =
            -- TODO vary this based on weapon / ...
            3

        shotType : Who -> OngoingFight -> Generator ShotType
        shotType who ongoing =
            let
                availableAp =
                    playerAp who ongoing

                chanceToHit : ShotType -> Float
                chanceToHit shot =
                    toFloat
                        (Logic.unarmedChanceToHit
                            { attackerSpecial = player_ who ongoing |> .special
                            , targetSpecial = player_ (theOther who) ongoing |> .special
                            , distanceHexes = ongoing.distanceHexes
                            , shotType = shot
                            }
                        )
                        / 100
            in
            Random.weighted
                ( chanceToHit NormalShot, NormalShot )
                (if availableAp >= attackApCost { isAimedShot = True } then
                    ShotType.allAimed
                        |> List.map
                            (\shot ->
                                ( chanceToHit (AimedShot shot)
                                , AimedShot shot
                                )
                            )

                 else
                    []
                )

        attackApCost : { isAimedShot : Bool } -> Int
        attackApCost r =
            baseApCost + ShotType.apCostPenalty r

        rollDamage : Who -> OngoingFight -> ShotType -> Generator Int
        rollDamage who ongoing shotType_ =
            -- TODO plug in the actual damage calculation
            Random.constant 3

        attack : Who -> OngoingFight -> Generator OngoingFight
        attack who ongoing =
            let
                other : Who
                other =
                    theOther who
            in
            -- TODO for now, everything is unarmed
            shotType who ongoing
                |> Random.andThen
                    (\shot ->
                        let
                            apCost =
                                attackApCost { isAimedShot = ShotType.isAimed shot }
                        in
                        if ongoing.distanceHexes == 0 && playerAp who ongoing >= apCost then
                            rollDamage who ongoing shot
                                |> Random.map
                                    (\damage ->
                                        ongoing
                                            |> addLog who
                                                (Attack
                                                    { damage = damage
                                                    , shotType = shot
                                                    , remainingHp = .hp (player_ other ongoing) - damage
                                                    }
                                                )
                                            |> subtractAp who apCost
                                            |> updatePlayer other (SPlayer.subtractHp damage)
                                    )

                        else
                            Random.constant ongoing
                    )

        comeCloser : Who -> OngoingFight -> Generator OngoingFight
        comeCloser who ongoing =
            -- TODO based on equipped weapon choose whether you need to move nearer to the opponent or whether it's good enough now
            -- Eg. unarmed needs distance 0
            -- Melee might need distance <2 and might prefer distance 0
            -- Small guns might need distance <35 and prefer the largest where the chance to hit is ~95% or something
            -- TODO currently everything is unarmed.
            if ongoing.distanceHexes <= 0 then
                Random.constant ongoing

            else
                let
                    maxPossibleMove : Int
                    maxPossibleMove =
                        min ongoing.distanceHexes (playerAp who ongoing)
                in
                ongoing
                    |> addLog who
                        (ComeCloser
                            { hexes = maxPossibleMove
                            , remainingDistanceHexes = ongoing.distanceHexes - maxPossibleMove
                            }
                        )
                    |> subtractDistance maxPossibleMove
                    |> subtractAp who maxPossibleMove
                    |> Random.constant

        subtractDistance : Int -> OngoingFight -> OngoingFight
        subtractDistance n ongoing =
            { ongoing | distanceHexes = ongoing.distanceHexes - n }

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
            if ongoing.attacker.hp > 0 && ongoing.target.hp > 0 then
                fn ongoing

            else
                Random.constant ongoing

        updatePlayer : Who -> (SPlayer -> SPlayer) -> OngoingFight -> OngoingFight
        updatePlayer who fn ongoing =
            case who of
                Attacker ->
                    { ongoing | attacker = fn ongoing.attacker }

                Target ->
                    { ongoing | target = fn ongoing.target }

        finalizeFight : OngoingFight -> FightInfo
        finalizeFight ongoing =
            let
                result : FightResult
                result =
                    if ongoing.attacker.hp <= 0 && ongoing.target.hp <= 0 then
                        BothDead

                    else if ongoing.attacker.hp <= 0 then
                        TargetWon
                            { capsGained = ongoing.attacker.caps
                            , xpGained = Logic.xpGained { damageDealt = initPlayers.attacker.hp }
                            }

                    else if ongoing.target.hp <= 0 then
                        AttackerWon
                            { capsGained = ongoing.target.caps
                            , xpGained = Logic.xpGained { damageDealt = initPlayers.target.hp }
                            }

                    else
                        NobodyDead

                final : OngoingFight
                final =
                    let
                        withoutTick : OngoingFight
                        withoutTick =
                            ongoing
                                |> updatePlayer Attacker (SPlayer.subtractTicks 1)
                    in
                    case result of
                        BothDead ->
                            withoutTick

                        NobodyDead ->
                            withoutTick

                        TargetAlreadyDead ->
                            withoutTick

                        AttackerWon { xpGained, capsGained } ->
                            withoutTick
                                |> updatePlayer Attacker (SPlayer.addXp xpGained)
                                |> updatePlayer Attacker (SPlayer.addCaps capsGained)
                                |> updatePlayer Target (SPlayer.subtractCaps capsGained)
                                |> updatePlayer Attacker SPlayer.incWins
                                |> updatePlayer Target SPlayer.incLosses

                        TargetWon { xpGained, capsGained } ->
                            withoutTick
                                |> updatePlayer Target (SPlayer.addXp xpGained)
                                |> updatePlayer Target (SPlayer.addCaps capsGained)
                                |> updatePlayer Attacker (SPlayer.subtractCaps capsGained)
                                |> updatePlayer Target SPlayer.incWins
                                |> updatePlayer Attacker SPlayer.incLosses
            in
            { attacker = final.attacker
            , target = final.target
            , log = List.reverse final.reverseLog
            , result = result
            }

        -- AP costs:
        -- movement takes 1 AP per hex
        -- based on various factors attacks take ~5 AP
    in
    initialFight
        |> Random.andThen (turn Attacker)
        |> Random.andThen (turn Target)
        |> Random.andThen turnsBySequenceLoop
        |> Random.map finalizeFight


targetAlreadyDead :
    { attacker : SPlayer
    , target : SPlayer
    }
    -> FightInfo
targetAlreadyDead { attacker, target } =
    { attacker = attacker
    , target = target
    , log = []
    , result = TargetAlreadyDead
    }
