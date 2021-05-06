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
import Data.Fight.Critical as Critical exposing (Critical)
import Data.Fight.ShotType as ShotType exposing (AimedShot, ShotType(..))
import Data.Item as Item
import Data.Message as Message exposing (Message, Type(..))
import Data.Perk as Perk
import Data.Player exposing (SPlayer)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp
import Logic exposing (AttackStats)
import Random exposing (Generator)
import Random.Bool as Random
import Random.FloatExtra as Random
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

        attackerHasCautiousNaturePerk : Bool
        attackerHasCautiousNaturePerk =
            Perk.rank Perk.CautiousNature r.attacker.perks > 0

        targetHasCautiousNaturePerk : Bool
        targetHasCautiousNaturePerk =
            Perk.rank Perk.CautiousNature r.target.perks > 0

        attackerPerceptionWithBonuses : Int
        attackerPerceptionWithBonuses =
            r.attacker.special.perception
                + (if attackerHasCautiousNaturePerk then
                    3

                   else
                    0
                  )

        targetPerceptionWithBonuses : Int
        targetPerceptionWithBonuses =
            r.target.special.perception
                + (if targetHasCautiousNaturePerk then
                    3

                   else
                    0
                  )

        averageStartingDistance : Int
        averageStartingDistance =
            max attackerPerceptionWithBonuses targetPerceptionWithBonuses

        -- TODO for non-unarmed attacks check that the range is <= weapon's range
        startingDistance : Generator Int
        startingDistance =
            Random.normallyDistributedInt
                { average = averageStartingDistance
                , maxDeviation = 5
                }

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

                armorClass =
                    Logic.armorClass
                        { naturalArmorClass = opponent.naturalArmorClass
                        , equippedArmor = opponent.equippedArmor
                        }
            in
            Logic.unarmedChanceToHit
                { attackerSpecial = opponent.special
                , attackerAddedSkillPercentages = opponent.addedSkillPercentages
                , distanceHexes = ongoing.distanceHexes
                , shotType = shot
                , targetArmorClass = armorClass
                }

        shotType : Who -> OngoingFight -> Generator ( ShotType, Int )
        shotType who ongoing =
            let
                availableAp =
                    opponentAp who ongoing

                shotAndChance : ShotType -> ( Float, ( ShotType, Int ) )
                shotAndChance shot =
                    let
                        chance : Int
                        chance =
                            chanceToHit who ongoing shot
                    in
                    ( toFloat chance, ( shot, chance ) )
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

        rollDamageAndCriticalInfo : Who -> OngoingFight -> ShotType -> Maybe Critical.EffectCategory -> Generator ( Int, Maybe ( List Critical.Effect, String ) )
        rollDamageAndCriticalInfo who ongoing shotType_ maybeCriticalEffectCategory =
            let
                opponent =
                    opponent_ who ongoing

                otherOpponent =
                    opponent_ (Fight.theOther who) ongoing

                criticalSpec : Maybe Critical.Spec
                criticalSpec =
                    maybeCriticalEffectCategory
                        |> Maybe.map
                            (\criticalEffectCategory ->
                                let
                                    aimedShot : AimedShot
                                    aimedShot =
                                        ShotType.toAimed shotType_
                                in
                                case otherOpponent.type_ of
                                    Fight.Player _ ->
                                        -- TODO gender -> womanCriticalSpec
                                        Enemy.manCriticalSpec aimedShot criticalEffectCategory

                                    Fight.Npc enemyType ->
                                        Enemy.criticalSpec enemyType aimedShot criticalEffectCategory
                            )

                criticalGenerator : Generator (Maybe Critical)
                criticalGenerator =
                    case criticalSpec of
                        Nothing ->
                            Random.constant Nothing

                        Just spec ->
                            Random.map Just <| rollCritical spec otherOpponent
            in
            Random.map2
                (\damage maybeCritical ->
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

                        armorIgnore =
                            -- TODO armor ignoring attacks
                            0

                        damageThreshold =
                            -- TODO we're not dealing with plasma/... right now, only _normal_ DT
                            toFloat <|
                                Logic.damageThresholdNormal
                                    { naturalDamageThresholdNormal =
                                        case otherOpponent.type_ of
                                            Fight.Player _ ->
                                                0

                                            Fight.Npc enemyType ->
                                                Enemy.damageThresholdNormal enemyType
                                    , equippedArmor = otherOpponent.equippedArmor
                                    }

                        damageResistance =
                            -- TODO we're not dealing with plasma/... right now, only _normal_ DR
                            toFloat <|
                                Logic.damageResistanceNormal
                                    { naturalDamageResistanceNormal =
                                        case otherOpponent.type_ of
                                            Fight.Player _ ->
                                                0

                                            Fight.Npc enemyType ->
                                                Enemy.damageResistanceNormal enemyType
                                    , equippedArmor = otherOpponent.equippedArmor
                                    }

                        ammoDamageResistanceModifier =
                            -- TODO ammo
                            0

                        criticalHitDamageMultiplier : Int
                        criticalHitDamageMultiplier =
                            maybeCritical
                                |> Maybe.map .damageMultiplier
                                |> Maybe.withDefault 2

                        maybeCriticalInfo =
                            Maybe.map
                                (\critical -> ( critical.effects, critical.message ))
                                maybeCritical
                    in
                    ( -- Taken from https://falloutmods.fandom.com/wiki/Fallout_engine_calculations#Damage_and_combat_calculations
                      -- TODO check this against the code in https://fallout-archive.fandom.com/wiki/Fallout_and_Fallout_2_combat#Ranged_combat_2
                      round <|
                        (((damage_ + rangedBonus)
                            * (ammoDamageMultiplier / ammoDamageDivisor)
                            * (toFloat criticalHitDamageMultiplier / 2)
                         )
                            - (damageThreshold / max 1 (5 * armorIgnore))
                        )
                            * ((100
                                    - max 0 (damageResistance / max 1 (5 * armorIgnore))
                                    + ammoDamageResistanceModifier
                               )
                                / 100
                              )
                    , maybeCriticalInfo
                    )
                )
                (Random.int
                    opponent.attackStats.minDamage
                    opponent.attackStats.maxDamage
                )
                criticalGenerator

        attack : Who -> OngoingFight -> Generator OngoingFight
        attack who ongoing =
            let
                opponent =
                    opponent_ who ongoing

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
                            Random.int 1 100
                                |> Random.andThen
                                    (\roll ->
                                        let
                                            hasHit : Bool
                                            hasHit =
                                                roll <= chance
                                        in
                                        -- TODO critical misses according to inspiration/fo2-calc/fo2calg.pdf
                                        if hasHit then
                                            let
                                                rollCriticalChanceBonus : Int
                                                rollCriticalChanceBonus =
                                                    (chance - roll) // 10

                                                baseCriticalChance : Int
                                                baseCriticalChance =
                                                    Logic.unarmedBaseCriticalChance
                                                        { special = opponent.special
                                                        , hasFinesseTrait = Trait.isSelected Trait.Finesse opponent.traits
                                                        , moreCriticalPerkRanks = Perk.rank Perk.MoreCriticals opponent.perks
                                                        , hasSlayerPerk = Perk.rank Perk.Slayer opponent.perks > 0
                                                        }

                                                criticalChance : Int
                                                criticalChance =
                                                    min 100 <| baseCriticalChance + rollCriticalChanceBonus
                                            in
                                            Random.weightedBool (toFloat criticalChance / 100)
                                                |> Random.andThen
                                                    (\isCritical ->
                                                        let
                                                            criticalEffectCategory =
                                                                if isCritical then
                                                                    let
                                                                        betterCriticalsPerkBonus : Int
                                                                        betterCriticalsPerkBonus =
                                                                            if Perk.rank Perk.BetterCriticals opponent.perks > 0 then
                                                                                20

                                                                            else
                                                                                0

                                                                        heavyHandedTraitPenalty : Int
                                                                        heavyHandedTraitPenalty =
                                                                            if Trait.isSelected Trait.HeavyHanded opponent.traits then
                                                                                -30

                                                                            else
                                                                                0

                                                                        baseCriticalEffect : Generator Int
                                                                        baseCriticalEffect =
                                                                            Random.int 1 100
                                                                    in
                                                                    baseCriticalEffect
                                                                        |> Random.map
                                                                            (\base ->
                                                                                Just <|
                                                                                    Critical.toCategory <|
                                                                                        base
                                                                                            + betterCriticalsPerkBonus
                                                                                            + heavyHandedTraitPenalty
                                                                            )

                                                                else
                                                                    Random.constant Nothing
                                                        in
                                                        criticalEffectCategory
                                                            |> Random.andThen (rollDamageAndCriticalInfo who ongoing shot)
                                                            |> Random.map
                                                                (\( damage, maybeCriticalEffectsAndMessage ) ->
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
            , perks = Dict_.empty
            , caps = caps
            , equippedArmor = Enemy.equippedArmor enemyType
            , naturalArmorClass = Enemy.naturalArmorClass enemyType
            , attackStats =
                -- TODO for now it's all unarmed
                Logic.unarmedAttackStats
                    { special = special
                    , unarmedSkill = unarmedSkill
                    , traits = traits
                    , perks = Dict_.empty
                    , level =
                        -- TODO what to do? What damage ranges do enemies really have in FO2?
                        1
                    , npcExtraBonus = Enemy.meleeDamageBonus enemyType
                    }
            , addedSkillPercentages = addedSkillPercentages
            , special =
                -- Enemies never have anything else than base special (no traits, perks, ...)
                special
            }
        )
        (Enemy.caps enemyType)


playerOpponent : SPlayer -> Opponent
playerOpponent player =
    let
        naturalArmorClass : Int
        naturalArmorClass =
            Logic.naturalArmorClass
                { hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                , special = player.special
                }

        sequence : Int
        sequence =
            Logic.sequence
                { perception = player.special.perception
                , hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                , earlierSequencePerkRank = Perk.rank Perk.EarlierSequence player.perks
                }

        actionPoints : Int
        actionPoints =
            Logic.actionPoints
                { hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , special = player.special
                }

        attackStats : AttackStats
        attackStats =
            Logic.unarmedAttackStats
                { special = player.special
                , unarmedSkill = Skill.get player.special player.addedSkillPercentages Skill.Unarmed
                , level = Xp.currentLevel player.xp
                , perks = player.perks
                , traits = player.traits
                , npcExtraBonus = 0
                }
    in
    { type_ = Fight.Player player.name
    , hp = player.hp
    , maxHp = player.maxHp
    , maxAp = actionPoints
    , sequence = sequence
    , traits = player.traits
    , perks = player.perks
    , caps = player.caps
    , equippedArmor = player.equippedArmor |> Maybe.map .kind
    , naturalArmorClass = naturalArmorClass
    , attackStats = attackStats
    , addedSkillPercentages = player.addedSkillPercentages
    , special = player.special
    }


rollCritical : Critical.Spec -> Opponent -> Generator Critical
rollCritical spec opponent =
    let
        withoutStatCheck =
            { damageMultiplier = spec.damageMultiplier
            , effects = spec.effects
            , message = spec.message
            }
    in
    case spec.statCheck of
        Nothing ->
            Random.constant withoutStatCheck

        Just check ->
            let
                currentStat : Int
                currentStat =
                    Special.get check.stat opponent.special

                modifiedStat : Int
                modifiedStat =
                    clamp 1 10 <| currentStat + check.modifier
            in
            Random.int 1 10
                |> Random.map
                    (\rolledStat ->
                        if rolledStat <= modifiedStat then
                            { damageMultiplier = spec.damageMultiplier
                            , effects = check.failureEffect :: spec.effects
                            , message = check.failureMessage
                            }

                        else
                            withoutStatCheck
                    )
