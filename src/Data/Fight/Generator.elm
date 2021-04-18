module Data.Fight.Generator exposing
    ( generator
    , targetAlreadyDead
    )

import Data.Fight as Fight exposing (FightAction(..), FightInfo, FightResult(..), Who(..))
import Data.Fight.ShotType as ShotType exposing (ShotType(..))
import Data.Message as Message exposing (Message, Type(..))
import Data.Perk as Perk
import Data.Player as Player exposing (SPlayer)
import Data.Player.SPlayer as SPlayer
import Data.Skill as Skill
import Data.Trait as Trait
import Data.Xp as Xp
import Logic
import Random exposing (Generator)
import Random.Bool
import Time exposing (Posix)


type alias OngoingFight =
    { distanceHexes : Int
    , attacker : SPlayer
    , target : SPlayer
    , attackerAp : Int
    , targetAp : Int
    , reverseLog : List ( Who, FightAction )
    }


generator :
    Posix
    ->
        { attacker : SPlayer
        , target : SPlayer
        }
    ->
        Generator
            { finalAttacker : SPlayer
            , finalTarget : SPlayer
            , fightInfo : FightInfo
            }
generator currentTime initPlayers =
    let
        -- TODO for non-unarmed attacks check that the range is <= weapon's range
        startingDistance : Generator Int
        startingDistance =
            -- TODO vary this based on the Perception / perks / Outdoorsman / ...?
            Random.int 10 20

        attackerMaxAp : Int
        attackerMaxAp =
            Logic.actionPoints
                { hasBruiserTrait = Trait.isSelected Trait.Bruiser initPlayers.attacker.traits
                , special =
                    Logic.special
                        { baseSpecial = initPlayers.attacker.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser initPlayers.attacker.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted initPlayers.attacker.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame initPlayers.attacker.traits
                        , isNewChar = False
                        }
                }

        targetMaxAp : Int
        targetMaxAp =
            Logic.actionPoints
                { hasBruiserTrait = Trait.isSelected Trait.Bruiser initPlayers.target.traits
                , special =
                    Logic.special
                        { baseSpecial = initPlayers.target.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser initPlayers.target.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted initPlayers.target.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame initPlayers.target.traits
                        , isNewChar = False
                        }
                }

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
                        let
                            special =
                                Logic.special
                                    { baseSpecial = player.baseSpecial
                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                                    , isNewChar = False
                                    }
                        in
                        negate <|
                            Logic.sequence
                                { perception = special.perception
                                , hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                                , earlierSequencePerkRank = Perk.rank Perk.EarlierSequence player.perks
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
                    player_ (Fight.theOther who) ongoing |> .hp

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

                player =
                    player_ who ongoing

                otherPlayer =
                    player_ (Fight.theOther who) ongoing

                chanceToHit : ShotType -> Float
                chanceToHit shot =
                    toFloat
                        (Logic.unarmedChanceToHit
                            { attackerSpecial =
                                Logic.special
                                    { baseSpecial = player.baseSpecial
                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                                    , isNewChar = False
                                    }
                            , targetSpecial =
                                Logic.special
                                    { baseSpecial = otherPlayer.baseSpecial
                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser otherPlayer.traits
                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted otherPlayer.traits
                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame otherPlayer.traits
                                    , isNewChar = False
                                    }
                            , attackerSkills = player.addedSkillPercentages
                            , distanceHexes = ongoing.distanceHexes
                            , shotType = shot
                            , targetHasKamikazeTrait = Trait.isSelected Trait.Kamikaze otherPlayer.traits
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

        attackStats who ongoing =
            let
                player =
                    player_ who ongoing

                finalSpecial =
                    Logic.special
                        { baseSpecial = player.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                        , isNewChar = False
                        }
            in
            Logic.unarmedAttackStats
                { finalSpecial = finalSpecial
                , unarmedSkill = Skill.get finalSpecial player.addedSkillPercentages Skill.Unarmed
                , level = Xp.currentLevel player.xp
                , perks = player.perks
                , traits = player.traits
                }

        rollDamage : Who -> OngoingFight -> ShotType -> Generator Int
        rollDamage who ongoing _ =
            let
                stats =
                    attackStats who ongoing
            in
            Random.int stats.minDamage stats.maxDamage
                |> Random.map
                    (\damage ->
                        let
                            damage_ =
                                toFloat damage

                            rangedBonus =
                                -- TODO ranged attacks and perks
                                0

                            ammoDamageMultiplier =
                                -- TODO ammo in combat
                                1

                            ammoDamageDivisor =
                                -- TODO ammo in combat
                                1

                            criticalHitDamageMultiplier =
                                -- TODO critical hits
                                2

                            armorIgnore =
                                -- TODO armor ignoring attacks
                                0

                            armorDamageThreshold =
                                -- TODO armor
                                0

                            armorDamageResistance =
                                -- TODO armor
                                0

                            ammoDamageResistanceModifier =
                                -- TODO ammo
                                0
                        in
                        -- Taken from https://falloutmods.fandom.com/wiki/Fallout_engine_calculations#Damage_and_combat_calculations
                        -- TODO check this against the code in https://fallout-archive.fandom.com/wiki/Fallout_and_Fallout_2_combat#Ranged_combat_2
                        round <|
                            (((damage_ + rangedBonus)
                                * (ammoDamageMultiplier / ammoDamageDivisor)
                                * (criticalHitDamageMultiplier / 2)
                              -- * (combatDifficultyMultiplier / 100)
                             )
                                - (armorDamageThreshold / max 1 (5 * armorIgnore))
                            )
                                * ((100
                                        - max 0 (armorDamageResistance / max 1 (5 * armorIgnore))
                                        + ammoDamageResistanceModifier
                                   )
                                    / 100
                                  )
                    )

        attack : Who -> OngoingFight -> Generator OngoingFight
        attack who ongoing =
            let
                other : Who
                other =
                    Fight.theOther who
            in
            -- TODO for now, everything is unarmed
            shotType who ongoing
                |> Random.andThen
                    (\shot ->
                        let
                            apCost =
                                attackApCost { isAimedShot = ShotType.isAimed shot }

                            player =
                                player_ who ongoing

                            otherPlayer =
                                player_ other ongoing
                        in
                        if ongoing.distanceHexes == 0 && playerAp who ongoing >= apCost then
                            let
                                chanceToHit =
                                    toFloat
                                        (Logic.unarmedChanceToHit
                                            { attackerSpecial =
                                                Logic.special
                                                    { baseSpecial = player.baseSpecial
                                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                                                    , isNewChar = False
                                                    }
                                            , targetSpecial =
                                                Logic.special
                                                    { baseSpecial = otherPlayer.baseSpecial
                                                    , hasBruiserTrait = Trait.isSelected Trait.Bruiser otherPlayer.traits
                                                    , hasGiftedTrait = Trait.isSelected Trait.Gifted otherPlayer.traits
                                                    , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame otherPlayer.traits
                                                    , isNewChar = False
                                                    }
                                            , attackerSkills = player.addedSkillPercentages
                                            , distanceHexes = ongoing.distanceHexes
                                            , shotType = shot
                                            , targetHasKamikazeTrait = Trait.isSelected Trait.Kamikaze otherPlayer.traits
                                            }
                                        )
                                        / 100
                            in
                            Random.Bool.weightedBool chanceToHit
                                |> Random.andThen
                                    (\hasHit ->
                                        -- TODO critical misses, critical hits according to inspiration/fo2-calc/fo2calg.pdf
                                        if hasHit then
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
                                            ongoing
                                                |> addLog who (Miss { shotType = shot })
                                                |> subtractAp who apCost
                                                |> Random.constant
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

        finalizeFight :
            OngoingFight
            ->
                { finalAttacker : SPlayer
                , finalTarget : SPlayer
                , fightInfo : FightInfo
                }
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

                fightInfo : FightInfo
                fightInfo =
                    { attackerName = initPlayers.attacker.name
                    , targetName = initPlayers.target.name
                    , log = List.reverse ongoing.reverseLog
                    , result = result
                    }

                messageForTarget : Message
                messageForTarget =
                    Message.new currentTime
                        (YouWereAttacked
                            { attacker = initPlayers.attacker.name
                            , fightInfo = fightInfo
                            }
                        )

                final : OngoingFight
                final =
                    let
                        withoutTickWithMessage : OngoingFight
                        withoutTickWithMessage =
                            ongoing
                                |> updatePlayer Attacker (SPlayer.subtractTicks 1)
                                |> updatePlayer Target (SPlayer.addMessage messageForTarget)
                    in
                    case result of
                        BothDead ->
                            withoutTickWithMessage

                        NobodyDead ->
                            withoutTickWithMessage

                        TargetAlreadyDead ->
                            withoutTickWithMessage

                        AttackerWon { xpGained, capsGained } ->
                            withoutTickWithMessage
                                |> updatePlayer Attacker
                                    (\player ->
                                        player
                                            |> SPlayer.addXp xpGained currentTime
                                            |> SPlayer.addCaps capsGained
                                            |> SPlayer.incWins
                                    )
                                |> updatePlayer Target
                                    (\player ->
                                        player
                                            |> SPlayer.subtractCaps capsGained
                                            |> SPlayer.incLosses
                                    )

                        TargetWon { xpGained, capsGained } ->
                            withoutTickWithMessage
                                |> updatePlayer Attacker
                                    (\player ->
                                        player
                                            |> SPlayer.subtractCaps capsGained
                                            |> SPlayer.incLosses
                                    )
                                |> updatePlayer Target
                                    (\player ->
                                        player
                                            |> SPlayer.addXp xpGained currentTime
                                            |> SPlayer.addCaps capsGained
                                            |> SPlayer.incWins
                                    )
            in
            { finalAttacker = final.attacker
            , finalTarget = final.target
            , fightInfo = fightInfo
            }
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
    ->
        { finalAttacker : SPlayer
        , finalTarget : SPlayer
        , fightInfo : FightInfo
        }
targetAlreadyDead { attacker, target } =
    { finalAttacker = attacker
    , finalTarget = target
    , fightInfo =
        { attackerName = attacker.name
        , targetName = target.name
        , log = []
        , result = TargetAlreadyDead
        }
    }
