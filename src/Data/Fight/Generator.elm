module Data.Fight.Generator exposing
    ( Fight
    , enemyOpponentGenerator
    , generator
    , playerOpponent
    , targetAlreadyDead
    )

import AssocList as Dict_
import AssocSet as Set_
import Data.Enemy as Enemy
import Data.Fight as Fight
    exposing
        ( FightAction(..)
        , FightInfo
        , FightResult(..)
        , Opponent
        , Who(..)
        )
import Data.Fight.ShotType as ShotType exposing (ShotType(..))
import Data.Message as Message exposing (Message, Type(..))
import Data.Perk as Perk
import Data.Player exposing (SPlayer)
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp
import Logic exposing (AttackStats)
import Random exposing (Generator)
import Random.Bool
import Time exposing (Posix)


type alias Fight =
    { finalAttacker : Opponent
    , finalTarget : Opponent
    , fightInfo : FightInfo
    , messageForTarget : Message
    }


type alias OngoingFight =
    { distanceHexes : Int
    , attacker : Opponent
    , target : Opponent
    , attackerAp : Int
    , targetAp : Int
    , reverseLog : List ( Who, FightAction )
    }


generator :
    { attacker : Opponent
    , target : Opponent
    , currentTime : Posix
    }
    -> Generator Fight
generator r =
    let
        attackerName : String
        attackerName =
            Fight.opponentName r.attacker.type_

        -- TODO for non-unarmed attacks check that the range is <= weapon's range
        startingDistance : Generator Int
        startingDistance =
            -- TODO vary this based on the Perception / perks / Outdoorsman / ...?
            Random.int 10 20

        initialFight : Generator OngoingFight
        initialFight =
            startingDistance
                |> Random.map
                    (\distance ->
                        { distanceHexes = distance
                        , attacker = r.attacker
                        , target = r.target
                        , attackerAp = r.attacker.maxAp
                        , targetAp = r.target.maxAp
                        , reverseLog = [ ( Attacker, Start { distanceHexes = distance } ) ]
                        }
                    )

        sequenceOrder : List Who
        sequenceOrder =
            [ ( Attacker, r.attacker )
            , ( Target, r.target )
            ]
                |> List.sortBy (\( _, opponent ) -> negate opponent.sequence)
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
                    { ongoing | attackerAp = r.attacker.maxAp }

                Target ->
                    { ongoing | targetAp = r.target.maxAp }

        opponent_ : Who -> OngoingFight -> Opponent
        opponent_ who ongoing =
            case who of
                Attacker ->
                    ongoing.attacker

                Target ->
                    ongoing.target

        opponentAp : Who -> OngoingFight -> Int
        opponentAp who ongoing =
            case who of
                Attacker ->
                    ongoing.attackerAp

                Target ->
                    ongoing.targetAp

        attackWhilePossible : Who -> OngoingFight -> Generator OngoingFight
        attackWhilePossible who ongoing =
            let
                myHp =
                    opponent_ who ongoing |> .hp

                otherHp =
                    opponent_ (Fight.theOther who) ongoing |> .hp

                minApCost =
                    attackApCost { isAimedShot = False }
            in
            if opponentAp who ongoing >= minApCost && otherHp > 0 && myHp > 0 then
                Random.constant ongoing
                    |> Random.andThen (attack who)
                    |> Random.andThen (attackWhilePossible who)

            else
                Random.constant ongoing

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

        chanceToHit : Who -> OngoingFight -> ShotType -> Int
        chanceToHit who ongoing shot =
            let
                opponent =
                    opponent_ who ongoing
            in
            Logic.unarmedChanceToHit
                { attackerFinalSpecial =
                    Logic.special
                        { baseSpecial = opponent.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser opponent.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted opponent.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame opponent.traits
                        , isNewChar = False
                        }
                , attackerAddedSkillPercentages = opponent.addedSkillPercentages
                , distanceHexes = ongoing.distanceHexes
                , shotType = shot
                , targetArmorClass = opponent.armorClass
                }

        shotType : Who -> OngoingFight -> Generator ( ShotType, Float )
        shotType who ongoing =
            let
                availableAp =
                    opponentAp who ongoing

                shotAndChance : ShotType -> ( Float, ( ShotType, Float ) )
                shotAndChance shot =
                    let
                        chance : Float
                        chance =
                            toFloat (chanceToHit who ongoing shot) / 100
                    in
                    ( chance, ( shot, chance ) )
            in
            Random.weighted
                (shotAndChance NormalShot)
                (if availableAp >= attackApCost { isAimedShot = True } then
                    ShotType.allAimed
                        |> List.map (AimedShot >> shotAndChance)

                 else
                    []
                )

        attackApCost : { isAimedShot : Bool } -> Int
        attackApCost r_ =
            baseApCost + ShotType.apCostPenalty r_

        rollDamage : Who -> OngoingFight -> ShotType -> Generator Int
        rollDamage who ongoing _ =
            let
                opponent =
                    opponent_ who ongoing

                otherOpponent =
                    opponent_ (Fight.theOther who) ongoing
            in
            Random.int
                opponent.attackStats.minDamage
                opponent.attackStats.maxDamage
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
                                toFloat <|
                                    -- TODO we're not dealing with plasma/... right now, only _normal_ DT
                                    case otherOpponent.type_ of
                                        Fight.Player _ ->
                                            -- TODO armor
                                            0

                                        Fight.Npc enemyType ->
                                            Enemy.damageThresholdNormal enemyType

                            armorDamageResistance =
                                toFloat <|
                                    -- TODO we're not dealing with plasma/... right now, only _normal_ DR
                                    case otherOpponent.type_ of
                                        Fight.Player _ ->
                                            -- TODO armor
                                            0

                                        Fight.Npc enemyType ->
                                            Enemy.damageResistanceNormal enemyType

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
                    (\( shot, chance ) ->
                        let
                            apCost =
                                attackApCost { isAimedShot = ShotType.isAimed shot }
                        in
                        if ongoing.distanceHexes == 0 && opponentAp who ongoing >= apCost then
                            Random.Bool.weightedBool chance
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
                                                                    , remainingHp = .hp (opponent_ other ongoing) - damage
                                                                    }
                                                                )
                                                            |> subtractAp who apCost
                                                            |> updateOpponent other (subtractHp damage)
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
                        min ongoing.distanceHexes (opponentAp who ongoing)
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

        updateOpponent : Who -> (Opponent -> Opponent) -> OngoingFight -> OngoingFight
        updateOpponent who fn ongoing =
            case who of
                Attacker ->
                    { ongoing | attacker = fn ongoing.attacker }

                Target ->
                    { ongoing | target = fn ongoing.target }

        finalizeFight : OngoingFight -> Fight
        finalizeFight ongoing =
            let
                targetIsPlayer : Bool
                targetIsPlayer =
                    Fight.isPlayer ongoing.target.type_

                result : FightResult
                result =
                    if ongoing.attacker.hp <= 0 && ongoing.target.hp <= 0 then
                        BothDead

                    else if ongoing.attacker.hp <= 0 then
                        if targetIsPlayer then
                            TargetWon
                                { capsGained = ongoing.attacker.caps
                                , xpGained = Logic.xpGained { damageDealt = r.attacker.hp }
                                }

                        else
                            -- Enemies have no use for your caps, so let's not make you lose them
                            TargetWon
                                { capsGained = 0
                                , xpGained = 0
                                }

                    else if ongoing.target.hp <= 0 then
                        case ongoing.target.type_ of
                            Fight.Player _ ->
                                AttackerWon
                                    { capsGained = ongoing.target.caps
                                    , xpGained = Logic.xpGained { damageDealt = r.target.hp }
                                    }

                            Fight.Npc enemyType ->
                                AttackerWon
                                    { capsGained = ongoing.target.caps
                                    , xpGained = Enemy.xp enemyType
                                    }

                    else
                        NobodyDead

                fightInfo : FightInfo
                fightInfo =
                    { attacker = r.attacker.type_
                    , target = r.target.type_
                    , log = List.reverse ongoing.reverseLog
                    , result = result
                    }

                messageForTarget : Message
                messageForTarget =
                    Message.new
                        r.currentTime
                        (YouWereAttacked
                            { attacker = attackerName
                            , fightInfo = fightInfo
                            }
                        )
            in
            { fightInfo = fightInfo
            , messageForTarget = messageForTarget
            , finalAttacker = ongoing.attacker
            , finalTarget = ongoing.target
            }
    in
    initialFight
        |> Random.andThen (turn Attacker)
        |> Random.andThen (turn Target)
        |> Random.andThen turnsBySequenceLoop
        |> Random.map finalizeFight


targetAlreadyDead :
    { attacker : Opponent
    , target : Opponent
    , currentTime : Posix
    }
    -> Fight
targetAlreadyDead { attacker, target, currentTime } =
    let
        attackerName =
            Fight.opponentName attacker.type_

        fightInfo =
            { attacker = Fight.Player <| Fight.opponentName attacker.type_
            , target = Fight.Player <| Fight.opponentName target.type_
            , log = []
            , result = TargetAlreadyDead
            }
    in
    { finalAttacker = attacker
    , finalTarget = target
    , fightInfo = fightInfo
    , messageForTarget =
        Message.new currentTime
            (YouWereAttacked
                { attacker = attackerName
                , fightInfo = fightInfo
                }
            )
    }


subtractHp : Int -> Opponent -> Opponent
subtractHp hp opponent =
    { opponent | hp = max 0 <| opponent.hp - hp }


enemyOpponentGenerator : Enemy.Type -> Generator Opponent
enemyOpponentGenerator enemyType =
    Random.map
        (\caps ->
            let
                hp : Int
                hp =
                    Enemy.hp enemyType

                addedSkillPercentages : Dict_.Dict Skill Int
                addedSkillPercentages =
                    Enemy.addedSkillPercentages enemyType

                traits : Set_.Set Trait
                traits =
                    Set_.empty

                special : Special
                special =
                    Enemy.special enemyType

                unarmedSkill : Int
                unarmedSkill =
                    Skill.get special addedSkillPercentages Skill.Unarmed
            in
            { type_ = Fight.Npc enemyType
            , hp = hp
            , maxHp = hp
            , maxAp = Enemy.actionPoints enemyType
            , sequence = Enemy.sequence enemyType
            , traits = traits
            , caps = caps
            , armorClass = Enemy.armorClass enemyType
            , attackStats =
                -- TODO for now it's all unarmed
                Logic.unarmedAttackStats
                    { finalSpecial = special
                    , unarmedSkill = unarmedSkill
                    , traits = traits
                    , perks = Dict_.empty
                    , level =
                        -- TODO what to do? What damage ranges do enemies really have in FO2?
                        1
                    , extraBonus = Enemy.meleeDamageBonus enemyType
                    }
            , addedSkillPercentages = addedSkillPercentages
            , baseSpecial =
                -- Enemies never have anything else than base special (no traits, perks, ...)
                special
            }
        )
        (Enemy.caps enemyType)


playerOpponent : SPlayer -> Opponent
playerOpponent player =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }

        armorClass : Int
        armorClass =
            Logic.armorClass
                { hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                , finalSpecial = finalSpecial
                }

        sequence : Int
        sequence =
            Logic.sequence
                { perception = finalSpecial.perception
                , hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                , earlierSequencePerkRank = Perk.rank Perk.EarlierSequence player.perks
                }

        actionPoints : Int
        actionPoints =
            Logic.actionPoints
                { hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , finalSpecial = finalSpecial
                }

        attackStats : AttackStats
        attackStats =
            Logic.unarmedAttackStats
                { finalSpecial = finalSpecial
                , unarmedSkill = Skill.get finalSpecial player.addedSkillPercentages Skill.Unarmed
                , level = Xp.currentLevel player.xp
                , perks = player.perks
                , traits = player.traits
                , extraBonus = 0 -- this is only for NPCs
                }
    in
    { type_ = Fight.Player player.name
    , hp = player.hp
    , maxHp = player.maxHp
    , maxAp = actionPoints
    , sequence = sequence
    , traits = player.traits
    , caps = player.caps
    , armorClass = armorClass
    , attackStats = attackStats
    , addedSkillPercentages = player.addedSkillPercentages
    , baseSpecial = player.baseSpecial
    }
