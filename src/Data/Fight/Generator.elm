module Data.Fight.Generator exposing
    ( Fight
    , enemyOpponentGenerator
    , generator
    , playerOpponent
    , targetAlreadyDead
    )

import Data.Enemy as Enemy exposing (addedSkillPercentages)
import Data.Fight as Fight exposing (Opponent, Who(..), CommandRejectionReason(..))
import Data.Fight.Critical as Critical exposing (Critical)
import Data.Fight.ShotType as ShotType exposing (AimedShot, ShotType(..))
import Data.FightStrategy as FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )
import Data.Item as Item exposing (Item)
import Data.Message as Message exposing (Content(..))
import Data.Perk as Perk exposing (Perk)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp
import Dict exposing (Dict)
import Dict.Extra as Dict
import List.Extra as List
import Logic exposing (AttackStats)
import Random exposing (Generator)
import Random.Bool as Random
import Random.FloatExtra as Random
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)
import Time exposing (Posix)


type alias Fight =
    { finalAttacker : Opponent
    , finalTarget : Opponent
    , fightInfo : Fight.Info
    , messageForTarget : Message.Content
    , messageForAttacker : Message.Content
    }


type alias OngoingFight =
    { distanceHexes : Int
    , attacker : Opponent
    , attackerAp : Int
    , attackerItemsUsed : SeqDict Item.Kind Int
    , target : Opponent
    , targetAp : Int
    , targetItemsUsed : SeqDict Item.Kind Int
    , reverseLog : List ( Who, Fight.Action )
    , actionsTaken : Int
    }


maxActionsTaken : Int
maxActionsTaken =
    1000


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


opponentItemsUsed : Who -> OngoingFight -> SeqDict Item.Kind Int
opponentItemsUsed who ongoing =
    case who of
        Attacker ->
            ongoing.attackerItemsUsed

        Target ->
            ongoing.targetItemsUsed


apFromPreviousTurn : Who -> OngoingFight -> Int
apFromPreviousTurn who ongoing =
    let
        opponent =
            opponent_ who ongoing

        usedAp =
            ongoing.reverseLog
                |> List.takeWhile (\( w, _ ) -> w == who)
                |> List.map (\( _, action ) -> apCost opponent action)
                |> List.sum
    in
    (opponent.maxAp - usedAp)
        |> max 0


apCost : Opponent -> Fight.Action -> Int
apCost opponent action =
    case action of
        Fight.Start _ ->
            0

        Fight.ComeCloser { hexes } ->
            hexes

        Fight.Attack r_ ->
            Logic.attackApCost
                { isAimedShot = ShotType.isAimed r_.shotType
                , hasBonusHthAttacksPerk = Perk.rank Perk.BonusHthAttacks opponent.perks > 0
                }

        Fight.Miss r_ ->
            Logic.attackApCost
                { isAimedShot = ShotType.isAimed r_.shotType
                , hasBonusHthAttacksPerk = Perk.rank Perk.BonusHthAttacks opponent.perks > 0
                }

        Fight.Heal _ ->
            Logic.healApCost

        Fight.DoNothing _ ->
            0


subtractAp : Who -> Fight.Action -> OngoingFight -> OngoingFight
subtractAp who action ongoing =
    let
        apToSubtract =
            apCost (opponent_ who ongoing) action
    in
    case who of
        Attacker ->
            { ongoing | attackerAp = max 0 <| ongoing.attackerAp - apToSubtract }

        Target ->
            { ongoing | targetAp = max 0 <| ongoing.targetAp - apToSubtract }


subtractDistance : Int -> OngoingFight -> OngoingFight
subtractDistance n ongoing =
    { ongoing | distanceHexes = ongoing.distanceHexes - n }


addLog : Who -> Fight.Action -> OngoingFight -> OngoingFight
addLog who action ongoing =
    { ongoing | reverseLog = ( who, action ) :: ongoing.reverseLog }


updateOpponent : Who -> (Opponent -> Opponent) -> OngoingFight -> OngoingFight
updateOpponent who fn ongoing =
    case who of
        Attacker ->
            { ongoing | attacker = fn ongoing.attacker }

        Target ->
            { ongoing | target = fn ongoing.target }


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
                -- Damage formulas taken from https://falloutmods.fandom.com/wiki/Fallout_engine_calculations#Damage_and_combat_calculations
                -- TODO check this against the code in https://fallout-archive.fandom.com/wiki/Fallout_and_Fallout_2_combat#Ranged_combat_2
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

                shouldIgnoreArmor : Bool
                shouldIgnoreArmor =
                    -- TODO armor ignoring attacks
                    False

                armorIgnore =
                    -- we'll later divide DT by this
                    if shouldIgnoreArmor then
                        5

                    else
                        1

                livingAnatomyBonus =
                    -- TODO check if the opponent is a living creature
                    if Perk.rank Perk.LivingAnatomy opponent.perks > 0 then
                        5

                    else
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
                            , toughnessPerkRanks = Perk.rank Perk.Toughness otherOpponent.perks
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

                finesseDamageResistanceModifier =
                    if Trait.isSelected Trait.Finesse opponent.traits then
                        30

                    else
                        0

                finalDamageResistance =
                    -- TODO how should this be ignored by armor-bypassing attacks?
                    -- TODO beware the +/- signs for the ammo modifier
                    damageResistance + ammoDamageResistanceModifier + finesseDamageResistanceModifier

                damageBeforeDamageResistance =
                    ((damage_ + rangedBonus)
                        * (ammoDamageMultiplier / ammoDamageDivisor)
                        * (toFloat criticalHitDamageMultiplier / 2)
                    )
                        - (damageThreshold / armorIgnore)

                finalDamage =
                    livingAnatomyBonus
                        + (if damageBeforeDamageResistance > 0 then
                            max 1 <|
                                round <|
                                    damageBeforeDamageResistance
                                        * ((100 - min 90 finalDamageResistance) / 100)

                           else
                            0
                          )
            in
            ( finalDamage
            , maybeCriticalInfo
            )
        )
        (Random.int
            opponent.attackStats.minDamage
            opponent.attackStats.maxDamage
        )
        criticalGenerator


bothAlive : OngoingFight -> Bool
bothAlive ongoing =
    ongoing.attacker.hp > 0 && ongoing.target.hp > 0


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

        targetName : String
        targetName =
            Fight.opponentName r.target.type_

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
                        , attackerAp = r.attacker.maxAp
                        , attackerItemsUsed = SeqDict.empty
                        , target = r.target
                        , targetAp = r.target.maxAp
                        , targetItemsUsed = SeqDict.empty
                        , reverseLog = [ ( Attacker, Fight.Start { distanceHexes = distance } ) ]
                        , actionsTaken = 0
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
            if bothAlive ongoing && not (givenUp ongoing) then
                ongoing
                    |> resetAp who
                    |> runStrategyRepeatedly who

            else
                Random.constant ongoing

        resetAp : Who -> OngoingFight -> OngoingFight
        resetAp who ongoing =
            case who of
                Attacker ->
                    { ongoing | attackerAp = r.attacker.maxAp }

                Target ->
                    { ongoing | targetAp = r.target.maxAp }

        turnsBySequenceLoop : OngoingFight -> Generator OngoingFight
        turnsBySequenceLoop ongoing =
            if bothAlive ongoing && not (givenUp ongoing) then
                turnsBySequence sequenceOrder ongoing
                    |> Random.andThen turnsBySequenceLoop

            else
                Random.constant ongoing

        turnsBySequence : List Who -> OngoingFight -> Generator OngoingFight
        turnsBySequence remaining ongoing =
            if bothAlive ongoing && not (givenUp ongoing) then
                case remaining of
                    [] ->
                        Random.constant ongoing

                    current :: rest ->
                        turn current ongoing
                            |> Random.andThen (turnsBySequence rest)

            else
                Random.constant ongoing

        finalizeFight : OngoingFight -> Fight
        finalizeFight ongoing =
            let
                targetIsPlayer : Bool
                targetIsPlayer =
                    Fight.isPlayer ongoing.target.type_

                result : Fight.Result
                result =
                    if givenUp ongoing then
                        Fight.NobodyDeadGivenUp

                    else if ongoing.attacker.hp <= 0 && ongoing.target.hp <= 0 then
                        Fight.BothDead

                    else if ongoing.attacker.hp <= 0 then
                        if targetIsPlayer then
                            Fight.TargetWon
                                { capsGained =
                                    Logic.playerCombatCapsGained
                                        { loserCaps = ongoing.attacker.caps
                                        , damageDealt = r.attacker.hp
                                        , loserMaxHp = ongoing.attacker.maxHp
                                        }
                                , xpGained =
                                    Logic.xpGained
                                        { baseXpGained =
                                            Logic.playerCombatXpGained
                                                { damageDealt = r.attacker.hp
                                                , loserLevel = Xp.currentLevel <| Fight.opponentXp r.attacker.type_
                                                , winnerLevel = Xp.currentLevel <| Fight.opponentXp r.target.type_
                                                }
                                        , swiftLearnerPerkRanks = Perk.rank Perk.SwiftLearner ongoing.target.perks
                                        }
                                , itemsGained = ongoing.attacker.drops
                                }

                        else
                            -- Enemies have no use for your caps, so let's not make you lose them
                            Fight.TargetWon
                                { capsGained = 0
                                , xpGained = 0
                                , itemsGained = []
                                }

                    else if ongoing.target.hp <= 0 then
                        case ongoing.target.type_ of
                            Fight.Player _ ->
                                Fight.AttackerWon
                                    { capsGained =
                                        Logic.playerCombatCapsGained
                                            { loserCaps = ongoing.target.caps
                                            , damageDealt = r.target.hp
                                            , loserMaxHp = ongoing.target.maxHp
                                            }
                                    , xpGained =
                                        Logic.xpGained
                                            { baseXpGained =
                                                Logic.playerCombatXpGained
                                                    { damageDealt = r.target.hp
                                                    , loserLevel = Xp.currentLevel <| Fight.opponentXp r.target.type_
                                                    , winnerLevel = Xp.currentLevel <| Fight.opponentXp r.attacker.type_
                                                    }
                                            , swiftLearnerPerkRanks = Perk.rank Perk.SwiftLearner ongoing.attacker.perks
                                            }
                                    , itemsGained = ongoing.target.drops
                                    }

                            Fight.Npc enemyType ->
                                Fight.AttackerWon
                                    { capsGained = ongoing.target.caps
                                    , xpGained =
                                        Logic.xpGained
                                            { baseXpGained = Enemy.xp enemyType
                                            , swiftLearnerPerkRanks = Perk.rank Perk.SwiftLearner ongoing.attacker.perks
                                            }
                                    , itemsGained = ongoing.target.drops
                                    }

                    else
                        Fight.NobodyDead

                fightInfo : Fight.Info
                fightInfo =
                    { attacker = r.attacker.type_
                    , target = r.target.type_
                    , log = List.reverse ongoing.reverseLog
                    , result = result
                    }

                messageForTarget =
                    YouWereAttacked
                        { attacker = attackerName
                        , fightInfo = fightInfo
                        }

                messageForAttacker =
                    YouAttacked
                        { target = targetName
                        , fightInfo = fightInfo
                        }
            in
            { fightInfo = fightInfo
            , messageForTarget = messageForTarget
            , messageForAttacker = messageForAttacker
            , finalAttacker = ongoing.attacker
            , finalTarget = ongoing.target
            }
    in
    initialFight
        |> Random.andThen (turn Attacker)
        |> Random.andThen (turn Target)
        |> Random.andThen turnsBySequenceLoop
        |> Random.map finalizeFight


givenUp : OngoingFight -> Bool
givenUp ongoing =
    let
        threshold : Int
        threshold =
            20

        damageDealt : ( Who, Fight.Action ) -> Bool
        damageDealt ( _, action ) =
            case action of
                Fight.Attack { damage } ->
                    damage > 0

                _ ->
                    False
    in
    (ongoing.actionsTaken > threshold && not (List.any damageDealt (List.take threshold ongoing.reverseLog)))
        || (ongoing.actionsTaken >= maxActionsTaken)


runStrategyRepeatedly : Who -> OngoingFight -> Generator OngoingFight
runStrategyRepeatedly who ongoing =
    let
        opponent : Opponent
        opponent =
            opponent_ who ongoing

        go : OngoingFight -> Generator OngoingFight
        go currentOngoing =
            if bothAlive currentOngoing && not (givenUp currentOngoing) && opponentAp who currentOngoing > 0 then
                runStrategy opponent.fightStrategy who currentOngoing
                    |> Random.andThen
                        (\userResult ->
                            if userResult.ranCommandSuccessfully then
                                go userResult.nextOngoing

                            else
                                Random.constant userResult.nextOngoing
                        )

            else
                Random.constant currentOngoing
    in
    go ongoing


runStrategy :
    FightStrategy
    -> Who
    -> OngoingFight
    -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
runStrategy strategy who ongoing =
    let
        themWho : Who
        themWho =
            Fight.theOther who

        state : StrategyState
        state =
            { you = opponent_ who ongoing
            , them = opponent_ themWho ongoing
            , themWho = themWho
            , yourAp = opponentAp who ongoing
            , yourItemsUsed = opponentItemsUsed who ongoing
            , distanceHexes = ongoing.distanceHexes
            , ongoingFight = ongoing
            }

        command : Command
        command =
            evalStrategy state strategy
                |> Debug.log "Want to do"
    in
    runCommand who ongoing state command


runCommand :
    Who
    -> OngoingFight
    -> StrategyState
    -> Command
    -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
runCommand who ongoing state command =
    case command of
        Attack shotType ->
            attack who ongoing shotType

        AttackRandomly ->
            attackRandomly who ongoing

        Heal itemKind ->
            heal who ongoing itemKind

        MoveForward ->
            moveForward who ongoing

        DoWhatever ->
            FightStrategy.doWhatever
                |> evalStrategy state
                |> runCommand who ongoing state


rejectCommand : Who -> CommandRejectionReason -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
rejectCommand who reason ongoing =
    Random.constant
        { ranCommandSuccessfully = False
        , nextOngoing =
            { ongoing
                | actionsTaken = ongoing.actionsTaken + 1
                , reverseLog = ( who, Fight.DoNothing reason ) :: ongoing.reverseLog
            }
        }


finalizeCommand : OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
finalizeCommand ongoing =
    Random.constant
        { ranCommandSuccessfully = True
        , nextOngoing = { ongoing | actionsTaken = ongoing.actionsTaken + 1 }
        }


heal : Who -> OngoingFight -> Item.Kind -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
heal who ongoing itemKind =
    let
        opponent =
            opponent_ who ongoing
    in
    if itemCount itemKind opponent <= 0 then
        rejectCommand who Fight.Heal_ItemNotPresent ongoing

    else if not <| Item.isHealing itemKind then
        -- TODO validate strategies and tell user the item cannot heal when defining the strategy?
        {- We're not using <= because there might later be usages for items that
           damage you instead of healing? Who knows
        -}
        rejectCommand who Fight.Heal_ItemDoesNotHeal ongoing

    else if opponent.hp == opponent.maxHp then
        rejectCommand who Fight.Heal_AlreadyFullyHealed ongoing

    else
        Item.healAmountGenerator itemKind
            |> Random.andThen
                (\healedHp ->
                    let
                        newHp : Int
                        newHp =
                            opponent.hp + healedHp

                        action : Fight.Action
                        action =
                            Fight.Heal
                                { itemKind = itemKind
                                , healedHp = healedHp
                                , newHp = newHp
                                }
                    in
                    ongoing
                        |> addLog who action
                        |> updateOpponent who (addHp healedHp >> decItem itemKind)
                        |> subtractAp who action
                        |> incItemsUsed who itemKind
                        |> finalizeCommand
                )


decItem : Item.Kind -> Opponent -> Opponent
decItem kind opponent =
    { opponent
        | items =
            opponent.items
                |> Dict.map
                    (\_ item ->
                        if item.kind == kind && item.count > 0 then
                            { item | count = item.count - 1 }

                        else
                            item
                    )
                |> Dict.filter (\_ { count } -> count > 0)
    }


incItemsUsed : Who -> Item.Kind -> OngoingFight -> OngoingFight
incItemsUsed who itemKind ongoing =
    let
        inc dict =
            SeqDict.update itemKind
                (\maybeCount ->
                    case maybeCount of
                        Nothing ->
                            Just 1

                        Just count ->
                            Just <| count + 1
                )
                dict
    in
    case who of
        Attacker ->
            { ongoing | attackerItemsUsed = inc ongoing.attackerItemsUsed }

        Target ->
            { ongoing | targetItemsUsed = inc ongoing.targetItemsUsed }


itemCount : Item.Kind -> Opponent -> Int
itemCount kind opponent =
    opponent.items
        |> Dict.find (\_ item -> item.kind == kind)
        |> Maybe.map (Tuple.second >> .count)
        |> Maybe.withDefault 0


moveForward : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
moveForward who ongoing =
    if ongoing.distanceHexes <= 0 then
        rejectCommand who MoveForward_AlreadyNextToEachOther ongoing

    else
        -- TODO based on equipped weapon choose whether you need to move nearer to the opponent or whether it's good enough now
        -- Eg. unarmed needs distance 0
        -- Melee might need distance <2 and might prefer distance 0
        -- Small guns might need distance <35 and prefer the largest where the chance to hit is ~95% or something
        -- TODO currently everything is unarmed.
        let
            maxPossibleMove : Int
            maxPossibleMove =
                min ongoing.distanceHexes (opponentAp who ongoing)

            action : Fight.Action
            action =
                Fight.ComeCloser
                    { hexes = maxPossibleMove
                    , remainingDistanceHexes = ongoing.distanceHexes - maxPossibleMove
                    }
        in
        ongoing
            |> addLog who action
            |> subtractDistance maxPossibleMove
            |> subtractAp who action
            |> finalizeCommand


chanceToHit : Who -> OngoingFight -> ShotType -> Int
chanceToHit who ongoing shot =
    let
        opponent =
            opponent_ who ongoing

        other =
            Fight.theOther who

        otherOpponent =
            opponent_ other ongoing

        armorClass =
            Logic.armorClass
                { naturalArmorClass = otherOpponent.naturalArmorClass
                , equippedArmor = otherOpponent.equippedArmor
                , hasHthEvadePerk = Perk.rank Perk.HthEvade otherOpponent.perks > 0
                , unarmedSkill = Skill.get otherOpponent.special otherOpponent.addedSkillPercentages Skill.Unarmed
                , apFromPreviousTurn = apFromPreviousTurn other ongoing
                }
    in
    Logic.unarmedChanceToHit
        { attackerSpecial = opponent.special
        , attackerAddedSkillPercentages = opponent.addedSkillPercentages
        , distanceHexes = ongoing.distanceHexes
        , shotType = shot
        , targetArmorClass = armorClass
        }


attackRandomly : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attackRandomly who ongoing =
    let
        shotType : Generator ShotType
        shotType =
            let
                opponent =
                    opponent_ who ongoing

                availableAp =
                    opponentAp who ongoing

                aimedShotApCost : Int
                aimedShotApCost =
                    Logic.attackApCost
                        { isAimedShot = True
                        , hasBonusHthAttacksPerk = Perk.rank Perk.BonusHthAttacks opponent.perks > 0
                        }
            in
            Random.uniform
                NormalShot
                (if availableAp >= aimedShotApCost then
                    List.map AimedShot ShotType.allAimed

                 else
                    []
                )
    in
    shotType
        |> Random.andThen (attack who ongoing)


attack : Who -> OngoingFight -> ShotType -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attack who ongoing shotType =
    let
        opponent =
            opponent_ who ongoing

        other : Who
        other =
            Fight.theOther who

        apCost_ : Int
        apCost_ =
            Logic.attackApCost
                { isAimedShot = ShotType.isAimed shotType
                , hasBonusHthAttacksPerk = Perk.rank Perk.BonusHthAttacks opponent.perks > 0
                }

        chance : Int
        chance =
            chanceToHit who ongoing shotType
    in
    if ongoing.distanceHexes /= 0 then
        rejectCommand who Attack_NotCloseEnough ongoing

    else if opponentAp who ongoing < apCost_ then
        rejectCommand who Attack_NotEnoughAP ongoing

    else
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

                            attackStatsCriticalChanceBonus : Int
                            attackStatsCriticalChanceBonus =
                                opponent.attackStats.criticalChanceBonus

                            criticalChance : Int
                            criticalChance =
                                min 100 <| baseCriticalChance + rollCriticalChanceBonus + attackStatsCriticalChanceBonus
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
                                        |> Random.andThen (rollDamageAndCriticalInfo who ongoing shotType)
                                        |> Random.andThen
                                            (\( damage, maybeCriticalEffectsAndMessage ) ->
                                                let
                                                    action : Fight.Action
                                                    action =
                                                        Fight.Attack
                                                            { damage = damage
                                                            , shotType = shotType
                                                            , remainingHp = .hp (opponent_ other ongoing) - damage
                                                            , isCritical = maybeCriticalEffectsAndMessage /= Nothing
                                                            }
                                                in
                                                -- TODO use the critical effects and message!!
                                                ongoing
                                                    |> addLog who action
                                                    |> subtractAp who action
                                                    |> updateOpponent other (subtractHp damage)
                                                    |> finalizeCommand
                                            )
                                )

                    else
                        let
                            action : Fight.Action
                            action =
                                Fight.Miss { shotType = shotType }
                        in
                        ongoing
                            |> addLog who action
                            |> subtractAp who action
                            |> finalizeCommand
                )


type alias StrategyState =
    { you : Opponent
    , them : Opponent
    , themWho : Who
    , yourAp : Int
    , yourItemsUsed : SeqDict Item.Kind Int
    , distanceHexes : Int
    , ongoingFight : OngoingFight
    }


evalStrategy : StrategyState -> FightStrategy -> Command
evalStrategy state strategy =
    case strategy of
        Command command ->
            command

        If { condition, then_, else_ } ->
            if evalCondition state condition then
                evalStrategy state then_

            else
                evalStrategy state else_


evalCondition : StrategyState -> Condition -> Bool
evalCondition state condition =
    case condition of
        Or c1 c2 ->
            evalCondition state c1 || evalCondition state c2

        And c1 c2 ->
            evalCondition state c1 && evalCondition state c2

        OpponentIsPlayer ->
            Fight.isPlayer state.them.type_

        OpponentIsNPC ->
            Fight.isNPC state.them.type_

        Operator { op, value, number_ } ->
            operatorFn
                op
                (evalValue state value)
                number_


evalValue : StrategyState -> Value -> Int
evalValue state value =
    case value of
        MyHP ->
            state.you.hp

        MyAP ->
            state.yourAp

        MyItemCount itemKind ->
            state.you.items
                -- TODO should we do unique key instead of just kind???
                |> Dict.find (\_ item -> item.kind == itemKind)
                |> Maybe.map (Tuple.second >> .count)
                |> Maybe.withDefault 0

        ItemsUsed itemKind ->
            state.yourItemsUsed
                |> SeqDict.get itemKind
                |> Maybe.withDefault 0

        ChanceToHit shotType ->
            Logic.unarmedChanceToHit
                { attackerAddedSkillPercentages = state.you.addedSkillPercentages
                , attackerSpecial = state.you.special
                , distanceHexes = state.distanceHexes
                , shotType = shotType
                , targetArmorClass =
                    Logic.armorClass
                        { naturalArmorClass = state.them.naturalArmorClass
                        , equippedArmor = state.them.equippedArmor
                        , hasHthEvadePerk = Perk.rank Perk.HthEvade state.them.perks > 0
                        , unarmedSkill = Skill.get state.them.special state.them.addedSkillPercentages Skill.Unarmed
                        , apFromPreviousTurn = apFromPreviousTurn state.themWho state.ongoingFight
                        }
                }

        Distance ->
            state.distanceHexes


operatorFn : Operator -> (Int -> Int -> Bool)
operatorFn op =
    case op of
        LT_ ->
            (<)

        LTE ->
            (<=)

        EQ_ ->
            (==)

        NE ->
            (/=)

        GTE ->
            (>=)

        GT_ ->
            (>)


targetAlreadyDead :
    { attacker : Opponent
    , target : Opponent
    , currentTime : Posix
    }
    -> Fight
targetAlreadyDead r =
    let
        attackerName =
            Fight.opponentName r.attacker.type_

        targetName =
            Fight.opponentName r.target.type_

        fightInfo =
            { attacker = r.attacker.type_
            , target = r.target.type_
            , log = []
            , result = Fight.TargetAlreadyDead
            }

        messageForTarget =
            YouWereAttacked
                { attacker = attackerName
                , fightInfo = fightInfo
                }

        messageForAttacker =
            YouAttacked
                { target = targetName
                , fightInfo = fightInfo
                }
    in
    { finalAttacker = r.attacker
    , finalTarget = r.target
    , fightInfo = fightInfo
    , messageForTarget = messageForTarget
    , messageForAttacker = messageForAttacker
    }


subtractHp : Int -> Opponent -> Opponent
subtractHp hp opponent =
    { opponent | hp = max 0 <| opponent.hp - hp }


addHp : Int -> Opponent -> Opponent
addHp hp opponent =
    { opponent | hp = min opponent.maxHp <| opponent.hp + hp }


enemyOpponentGenerator : { hasFortuneFinderPerk : Bool } -> Int -> Enemy.Type -> Generator ( Opponent, Int )
enemyOpponentGenerator r lastItemId enemyType =
    Enemy.dropGenerator lastItemId (Enemy.dropSpec enemyType)
        |> Random.map
            (\( { caps, items }, newItemId ) ->
                let
                    caps_ : Int
                    caps_ =
                        if r.hasFortuneFinderPerk then
                            caps * 2

                        else
                            caps

                    hp : Int
                    hp =
                        Enemy.hp enemyType

                    addedSkillPercentages : SeqDict Skill Int
                    addedSkillPercentages =
                        Enemy.addedSkillPercentages enemyType

                    traits : SeqSet Trait
                    traits =
                        SeqSet.empty

                    special : Special
                    special =
                        Enemy.special enemyType

                    unarmedSkill : Int
                    unarmedSkill =
                        Skill.get special addedSkillPercentages Skill.Unarmed
                in
                ( { type_ = Fight.Npc enemyType
                  , hp = hp
                  , maxHp = hp
                  , maxAp = Enemy.actionPoints enemyType
                  , sequence = Enemy.sequence enemyType
                  , traits = traits
                  , perks = SeqDict.empty
                  , caps = caps_
                  , items = Dict.empty
                  , drops = items
                  , equippedArmor = Enemy.equippedArmor enemyType
                  , naturalArmorClass = Enemy.naturalArmorClass enemyType
                  , attackStats =
                        -- TODO for now it's all unarmed
                        Logic.unarmedAttackStats
                            { special = special
                            , unarmedSkill = unarmedSkill
                            , traits = traits
                            , perks = SeqDict.empty
                            , level =
                                -- TODO what to do? What damage ranges do enemies really have in FO2?
                                1
                            , npcExtraBonus = Enemy.meleeDamageBonus enemyType
                            }
                  , addedSkillPercentages = addedSkillPercentages
                  , special =
                        -- Enemies never have anything else than base special (no traits, perks, ...)
                        special
                  , fightStrategy = FightStrategy.doWhatever
                  }
                , newItemId
                )
            )


playerOpponent :
    { splayer
        | name : String
        , special : Special
        , perks : SeqDict Perk Int
        , traits : SeqSet Trait
        , hp : Int
        , maxHp : Int
        , xp : Int
        , caps : Int
        , addedSkillPercentages : SeqDict Skill Int
        , equippedArmor : Maybe Item
        , fightStrategy : FightStrategy
        , items : Dict Item.Id Item
    }
    -> Opponent
playerOpponent player =
    let
        naturalArmorClass : Int
        naturalArmorClass =
            Logic.naturalArmorClass
                { hasKamikazeTrait = Trait.isSelected Trait.Kamikaze player.traits
                , special = player.special
                , hasDodgerPerk = Perk.rank Perk.Dodger player.perks > 0
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
                , actionBoyPerkRanks = Perk.rank Perk.ActionBoy player.perks
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
    { type_ =
        Fight.Player
            { name = player.name
            , xp = player.xp
            }
    , hp = player.hp
    , maxHp = player.maxHp
    , maxAp = actionPoints
    , sequence = sequence
    , traits = player.traits
    , perks = player.perks
    , caps = player.caps
    , items = player.items
    , drops = []
    , equippedArmor = player.equippedArmor |> Maybe.map .kind
    , naturalArmorClass = naturalArmorClass
    , attackStats = attackStats
    , addedSkillPercentages = player.addedSkillPercentages
    , special = player.special
    , fightStrategy = player.fightStrategy
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
