module Data.Fight.Generator exposing
    ( Fight
    , OngoingFight
    , attack_
    , enemyOpponentGenerator
    , generator
    , playerOpponent
    , targetAlreadyDead
    )

import Data.Enemy as Enemy
import Data.Enemy.Type as EnemyType exposing (EnemyType)
import Data.Fight as Fight exposing (CommandRejectionReason(..), Opponent, Who(..))
import Data.Fight.AimedShot as AimedShot exposing (AimedShot)
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle(..))
import Data.Fight.Critical as Critical exposing (Critical)
import Data.Fight.DamageType as DamageType exposing (DamageType)
import Data.Fight.OpponentType as OpponentType
import Data.FightStrategy as FightStrategy
    exposing
        ( Command(..)
        , Condition(..)
        , FightStrategy(..)
        , Operator(..)
        , Value(..)
        )
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Message as Message exposing (Content(..))
import Data.Perk as Perk exposing (Perk)
import Data.Perk.Requirement exposing (requirements)
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
    , fightInfoForAttacker : Fight.Info
    , messageForTarget : Message.Content
    , messageForAttacker : Message.Content
    }


type alias OngoingFight =
    { distanceHexes : Int
    , attacker : Opponent
    , attackerAp : Int
    , attackerItemsUsed : SeqDict ItemKind.Kind Int
    , target : Opponent
    , targetAp : Int
    , targetItemsUsed : SeqDict ItemKind.Kind Int
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


opponentItemsUsed : Who -> OngoingFight -> SeqDict ItemKind.Kind Int
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
                |> currentTurnLog who
                |> List.map apCost
                |> List.sum
    in
    (opponent.maxAp - usedAp)
        |> max 0


apCost : Fight.Action -> Int
apCost action =
    case action of
        Fight.Start _ ->
            0

        Fight.ComeCloser { hexes } ->
            hexes

        Fight.Attack r_ ->
            r_.apCost

        Fight.Miss r_ ->
            r_.apCost

        Fight.Heal _ ->
            Logic.healApCost

        Fight.KnockedOut ->
            0

        Fight.StandUp r_ ->
            r_.apCost

        Fight.SkipTurn ->
            0

        Fight.FailToDoAnything _ ->
            0


subtractAp : Who -> Fight.Action -> OngoingFight -> OngoingFight
subtractAp who action ongoing =
    let
        apToSubtract =
            apCost action
    in
    case who of
        Attacker ->
            { ongoing | attackerAp = max 0 <| ongoing.attackerAp - apToSubtract }

        Target ->
            { ongoing | targetAp = max 0 <| ongoing.targetAp - apToSubtract }


subtractDistance : Int -> OngoingFight -> OngoingFight
subtractDistance n ongoing =
    { ongoing | distanceHexes = max 1 <| ongoing.distanceHexes - n }


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


rollCritical :
    Who
    -> OngoingFight
    -> AttackStyle
    -> Maybe Critical.EffectCategory
    -> Generator (Maybe Critical)
rollCritical who ongoing attackStyle maybeCriticalEffectCategory =
    let
        opponent =
            opponent_ who ongoing

        otherWho =
            Fight.theOther who

        otherOpponent =
            opponent_ otherWho ongoing

        criticalSpec : Maybe Critical.Spec
        criticalSpec =
            maybeCriticalEffectCategory
                |> Maybe.map
                    (\criticalEffectCategory ->
                        let
                            aimedShot : AimedShot
                            aimedShot =
                                AttackStyle.toAimed attackStyle
                                    |> Maybe.withDefault AimedShot.Torso
                        in
                        case otherOpponent.type_ of
                            OpponentType.Player _ ->
                                -- TODO gender -> womanCriticalSpec
                                Enemy.playerCriticalSpec aimedShot criticalEffectCategory

                            OpponentType.Npc enemyType ->
                                Enemy.criticalSpec enemyType aimedShot criticalEffectCategory
                    )
    in
    case criticalSpec of
        Nothing ->
            Random.constant Nothing

        Just spec ->
            let
                withoutStatCheck =
                    { damageMultiplier = spec.damageMultiplier
                    , effects = spec.effects
                    , message = spec.message
                    }
            in
            case spec.statCheck of
                Nothing ->
                    Random.constant (Just withoutStatCheck)

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
                                Just <|
                                    if rolledStat <= modifiedStat then
                                        { damageMultiplier = spec.damageMultiplier
                                        , effects = check.failureEffect :: spec.effects
                                        , message = check.failureMessage
                                        }

                                    else
                                        withoutStatCheck
                            )


rollDamage :
    Who
    -> OngoingFight
    -> AttackStyle
    -> Maybe Critical
    -> Generator Int
rollDamage who ongoing attackStyle maybeCritical =
    let
        opponent =
            opponent_ who ongoing

        otherOpponent =
            opponent_ (Fight.theOther who) ongoing

        usedAmmo_ : Logic.UsedAmmo
        usedAmmo_ =
            usedAmmo who ongoing

        damageType : DamageType
        damageType =
            Logic.weaponDamageType opponent.equippedWeapon

        attackStats : AttackStats
        attackStats =
            Logic.attackStats
                { special = opponent.special
                , addedSkillPercentages = opponent.addedSkillPercentages
                , level = opponent.level
                , perks = opponent.perks
                , traits = opponent.traits
                , equippedWeapon = opponent.equippedWeapon
                , crippledArms = crippledArms opponent
                , preferredAmmo = opponent.preferredAmmo
                , items = opponent.items
                , unarmedDamageBonus = opponent.unarmedDamageBonus
                , attackStyle = attackStyle
                }
    in
    Random.int
        attackStats.minDamage
        attackStats.maxDamage
        |> Random.map
            (\damage ->
                let
                    -- Damage formulas taken from https://falloutmods.fandom.com/wiki/Fallout_engine_calculations#Damage_and_combat_calculations
                    -- TODO check this against the code in https://fallout-archive.fandom.com/wiki/Fallout_and_Fallout_2_combat#Ranged_combat_2
                    -- This is also helpful: https://github.com/alexbatalov/fallout2-ce/blob/main/src/combat.cc
                    damage_ =
                        toFloat damage

                    ( ammoDamageMultiplier, ammoDamageDivisor ) =
                        case usedAmmo_ of
                            Logic.PreferredAmmo ( _, ammoKind, _ ) ->
                                ItemKind.ammoDamageModifier ammoKind

                            Logic.FallbackAmmo ( _, ammoKind, _ ) ->
                                ItemKind.ammoDamageModifier ammoKind

                            Logic.NoUsableAmmo ->
                                ( 1, 1 )

                            Logic.NoAmmoNeeded ->
                                ( 1, 1 )

                    isWeaponArmorPenetrating : Bool
                    isWeaponArmorPenetrating =
                        let
                            allGood () =
                                opponent.equippedWeapon
                                    |> Maybe.map ItemKind.isWeaponArmorPenetrating
                                    |> Maybe.withDefault False
                        in
                        case usedAmmo_ of
                            Logic.PreferredAmmo _ ->
                                allGood ()

                            Logic.FallbackAmmo _ ->
                                allGood ()

                            Logic.NoUsableAmmo ->
                                False

                            Logic.NoAmmoNeeded ->
                                False

                    isUnarmedAttackArmorPiercing : Bool
                    isUnarmedAttackArmorPiercing =
                        {- https://fallout.fandom.com/wiki/Unarmed_(Fallout)#Fallout_2_and_Fallout_Tactics_2

                           If we ever use the "named" unarmed attacks from the
                           "secondary" table (that cost more AP), this might become
                           True for some of them:

                           - Dragon Punch (PALM_STRIKE)
                           - Force Punch (PIERCING_STRIKE)
                           - Jump Kick (HOOK_KICK)
                           - Death Blossom Kick (PIERCING_KICK)

                           See Logic.meleeAttackStats.
                        -}
                        False

                    armorIgnoreDamageThresholdDivisor : Float
                    armorIgnoreDamageThresholdDivisor =
                        if
                            (isCriticalAttackArmorPiercing && not (damageType == DamageType.EMP))
                                || isWeaponArmorPenetrating
                                || isUnarmedAttackArmorPiercing
                        then
                            5

                        else
                            1

                    criticalAttackDamageResistanceDivisor : Float
                    criticalAttackDamageResistanceDivisor =
                        if isCriticalAttackArmorPiercing && not (damageType == DamageType.EMP) then
                            5

                        else
                            1

                    livingAnatomyBonus : Int
                    livingAnatomyBonus =
                        if
                            (Perk.rank Perk.LivingAnatomy opponent.perks > 0)
                                && Fight.isOpponentLivingCreature otherOpponent
                        then
                            5

                        else
                            0

                    damageThreshold : Float
                    damageThreshold =
                        toFloat <|
                            Logic.damageThreshold
                                { damageType = damageType
                                , opponentType = otherOpponent.type_
                                , equippedArmor = otherOpponent.equippedArmor
                                }

                    damageResistancePct : Int
                    damageResistancePct =
                        Logic.damageResistance
                            { damageType = damageType
                            , opponentType = otherOpponent.type_
                            , equippedArmor = otherOpponent.equippedArmor
                            , toughnessPerkRanks = Perk.rank Perk.Toughness otherOpponent.perks
                            }

                    criticalHitDamageMultiplier : Int
                    criticalHitDamageMultiplier =
                        maybeCritical
                            |> Maybe.map .damageMultiplier
                            |> Maybe.withDefault 2

                    isCriticalAttackArmorPiercing : Bool
                    isCriticalAttackArmorPiercing =
                        maybeCritical
                            |> Maybe.map (.effects >> List.member Critical.BypassArmor)
                            |> Maybe.withDefault False

                    ammoDamageResistanceModifierPct : Int
                    ammoDamageResistanceModifierPct =
                        case usedAmmo_ of
                            Logic.PreferredAmmo ( _, ammoKind, _ ) ->
                                ItemKind.ammoDamageResistanceModifier ammoKind

                            Logic.FallbackAmmo ( _, ammoKind, _ ) ->
                                ItemKind.ammoDamageResistanceModifier ammoKind

                            Logic.NoUsableAmmo ->
                                0

                            Logic.NoAmmoNeeded ->
                                0

                    finesseDamageResistanceModifierPct : Int
                    finesseDamageResistanceModifierPct =
                        if
                            Trait.isSelected Trait.Finesse opponent.traits
                                && (not isCriticalAttackArmorPiercing || damageType == DamageType.EMP)
                        then
                            30

                        else
                            0

                    finalDamageResistancePct : Int
                    finalDamageResistancePct =
                        damageResistancePct
                            + ammoDamageResistanceModifierPct
                            + finesseDamageResistanceModifierPct

                    damageBeforeDamageResistance =
                        (damage_
                            * (ammoDamageMultiplier / ammoDamageDivisor)
                            * (toFloat criticalHitDamageMultiplier / 2)
                        )
                            - (damageThreshold / armorIgnoreDamageThresholdDivisor)

                    finalDamage =
                        livingAnatomyBonus
                            + (if damageBeforeDamageResistance > 0 then
                                max 1 <|
                                    round <|
                                        damageBeforeDamageResistance
                                            / criticalAttackDamageResistanceDivisor
                                            * ((100 - min 90 (toFloat finalDamageResistancePct)) / 100)

                               else
                                0
                              )
                in
                finalDamage
            )


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
                |> Random.map (max 1)

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
                let
                    opponent =
                        opponent_ who ongoing
                in
                if opponent.losesNextTurn then
                    -- skip turn but also reset the "skip turn" flag
                    ongoing
                        |> updateOpponent who (\op -> { op | losesNextTurn = False })
                        |> Random.constant

                else if opponent.knockedOutTurns > 1 then
                    -- skip turn and decrease the number of turns to wait
                    ongoing
                        |> updateOpponent who (\op -> { op | knockedOutTurns = op.knockedOutTurns - 1 })
                        |> addLog who Fight.KnockedOut
                        |> Random.constant

                else if opponent.knockedOutTurns == 1 then
                    ongoing
                        |> updateOpponent who (\op -> { op | knockedOutTurns = 0 })
                        |> resetAp who
                        |> standUp who
                        |> updateAp (\ap -> ap - Logic.regainConciousnessApCost { maxAp = opponent.maxAp }) who
                        |> runStrategyRepeatedly who

                else
                    ongoing
                        |> resetAp who
                        |> (if opponent.isKnockedDown then
                                standUp who

                            else
                                identity
                           )
                        |> runStrategyRepeatedly who

            else
                Random.constant ongoing

        standUp who o =
            let
                opponent =
                    opponent_ who o

                standUpCost =
                    Logic.standUpApCost
                        { hasQuickRecoveryPerk =
                            Perk.rank Perk.QuickRecovery opponent.perks > 0
                        }
            in
            o
                |> updateAp (\ap -> ap - standUpCost) who
                |> updateOpponent who (\op -> { op | isKnockedDown = False })
                |> addLog who (Fight.StandUp { apCost = standUpCost })

        updateAp : (Int -> Int) -> Who -> OngoingFight -> OngoingFight
        updateAp fn who ongoing =
            case who of
                Attacker ->
                    { ongoing | attackerAp = max 0 <| fn ongoing.attackerAp }

                Target ->
                    { ongoing | targetAp = max 0 <| fn ongoing.targetAp }

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
                                , itemsGained =
                                    ongoing.attacker.drops
                                        |> List.filterMap
                                            (\( item, requirements ) ->
                                                if Enemy.areApplicable { perks = ongoing.target.perks } requirements then
                                                    Just item

                                                else
                                                    Nothing
                                            )
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
                            OpponentType.Player _ ->
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
                                    , itemsGained =
                                        ongoing.target.drops
                                            |> List.filterMap
                                                (\( item, requirements ) ->
                                                    if Enemy.areApplicable { perks = ongoing.attacker.perks } requirements then
                                                        Just item

                                                    else
                                                        Nothing
                                                )
                                    }

                            OpponentType.Npc enemyType ->
                                Fight.AttackerWon
                                    { capsGained = ongoing.target.caps
                                    , xpGained =
                                        Logic.xpGained
                                            { baseXpGained = EnemyType.xpReward enemyType
                                            , swiftLearnerPerkRanks = Perk.rank Perk.SwiftLearner ongoing.attacker.perks
                                            }
                                    , itemsGained =
                                        ongoing.target.drops
                                            |> List.filterMap
                                                (\( item, requirements ) ->
                                                    if Enemy.areApplicable { perks = ongoing.attacker.perks } requirements then
                                                        Just item

                                                    else
                                                        Nothing
                                                )
                                    }

                    else
                        Fight.NobodyDead

                fightInfoForTarget : Fight.Info
                fightInfoForTarget =
                    { attacker = r.attacker.type_
                    , target = r.target.type_
                    , log = List.reverse ongoing.reverseLog
                    , result = result
                    , attackerEquipment =
                        if Perk.rank Perk.Awareness ongoing.target.perks > 0 then
                            Just
                                { weapon = ongoing.attacker.equippedWeapon
                                , armor = ongoing.attacker.equippedArmor
                                }

                        else
                            Nothing
                    , targetEquipment =
                        Just
                            { weapon = ongoing.target.equippedWeapon
                            , armor = ongoing.target.equippedArmor
                            }
                    }

                fightInfoForAttacker : Fight.Info
                fightInfoForAttacker =
                    { attacker = r.attacker.type_
                    , target = r.target.type_
                    , log = List.reverse ongoing.reverseLog
                    , result = result
                    , attackerEquipment =
                        Just
                            { weapon = ongoing.attacker.equippedWeapon
                            , armor = ongoing.attacker.equippedArmor
                            }
                    , targetEquipment =
                        if Perk.rank Perk.Awareness ongoing.attacker.perks > 0 then
                            Just
                                { weapon = ongoing.target.equippedWeapon
                                , armor = ongoing.target.equippedArmor
                                }

                        else
                            Nothing
                    }

                messageForTarget =
                    YouWereAttacked
                        { attacker = attackerName
                        , fightInfo = fightInfoForTarget
                        }

                messageForAttacker =
                    YouAttacked
                        { target = targetName
                        , fightInfo = fightInfoForAttacker
                        }
            in
            { fightInfoForAttacker = fightInfoForAttacker
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
            evalStrategy who state strategy
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
        Attack attackCombination ->
            attack who ongoing attackCombination

        AttackRandomly ->
            attackRandomly who ongoing

        Heal itemKind ->
            heal who ongoing itemKind

        HealWithAnything ->
            healWithAnything who ongoing

        MoveForward ->
            moveForward who ongoing

        DoWhatever ->
            FightStrategy.doWhatever
                |> evalStrategy who state
                |> runCommand who ongoing state

        SkipTurn ->
            skipTurn who ongoing


currentTurnLog : Who -> List ( Who, Fight.Action ) -> List Fight.Action
currentTurnLog who log =
    log
        |> List.takeWhile (\( w, _ ) -> w == who)
        |> List.map Tuple.second


rejectCommand : Who -> CommandRejectionReason -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
rejectCommand who reason ongoing =
    let
        isFirst =
            currentTurnLog who ongoing.reverseLog
                |> List.isEmpty
    in
    Random.constant
        { ranCommandSuccessfully = False
        , nextOngoing =
            if isFirst then
                { ongoing
                    | actionsTaken = ongoing.actionsTaken + 1
                    , reverseLog = ( who, Fight.FailToDoAnything reason ) :: ongoing.reverseLog
                }

            else
                ongoing
        }


finalizeCommand : OngoingFight -> { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
finalizeCommand ongoing =
    { ranCommandSuccessfully = True
    , nextOngoing = { ongoing | actionsTaken = ongoing.actionsTaken + 1 }
    }


heal : Who -> OngoingFight -> ItemKind.Kind -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
heal who ongoing itemKind =
    let
        opponent =
            opponent_ who ongoing
    in
    if itemCount itemKind opponent <= 0 then
        rejectCommand who Fight.Heal_ItemNotPresent ongoing

    else if not <| ItemKind.isHealing itemKind then
        {- We're not using <= because there might later be usages for items that
           damage you instead of healing? Who knows
        -}
        rejectCommand who Fight.Heal_ItemDoesNotHeal ongoing

    else if opponent.hp == opponent.maxHp then
        rejectCommand who Fight.Heal_AlreadyFullyHealed ongoing

    else
        Logic.healAmountGenerator itemKind
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
                        |> Random.constant
                )


healWithAnything : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
healWithAnything who ongoing =
    let
        opponent =
            opponent_ who ongoing
    in
    if opponent.hp == opponent.maxHp then
        rejectCommand who Fight.HealWithAnything_AlreadyFullyHealed ongoing

    else
        case Dict.find (\_ item -> ItemKind.isHealing item.kind) opponent.items of
            Nothing ->
                rejectCommand who HealWithAnything_NoHealingItem ongoing

            Just ( _, healingItem ) ->
                heal who ongoing healingItem.kind


decItem : ItemKind.Kind -> Opponent -> Opponent
decItem kind opponent =
    subItem 1 kind opponent


{-| TODO require an Item.Id argument and do a Dict.update, or make player.items be SeqDict ItemKind.Kind Item or something?
-}
subItem : Int -> ItemKind.Kind -> Opponent -> Opponent
subItem n kind opponent =
    let
        isPreferredAmmo =
            opponent.preferredAmmo == Just kind

        isLast =
            itemCount kind opponent <= n
    in
    { opponent
        | items =
            opponent.items
                |> Dict.map
                    (\_ item ->
                        if item.kind == kind then
                            { item | count = item.count - n }

                        else
                            item
                    )
                |> Dict.filter (\_ { count } -> count > 0)
        , preferredAmmo =
            if isPreferredAmmo && isLast then
                Nothing

            else
                opponent.preferredAmmo
    }


addItemsUsed : Who -> ItemKind.Kind -> Int -> OngoingFight -> OngoingFight
addItemsUsed who itemKind n ongoing =
    let
        inc dict =
            SeqDict.update itemKind
                (\maybeCount ->
                    case maybeCount of
                        Nothing ->
                            Just n

                        Just count ->
                            Just <| count + n
                )
                dict
    in
    case who of
        Attacker ->
            { ongoing | attackerItemsUsed = inc ongoing.attackerItemsUsed }

        Target ->
            { ongoing | targetItemsUsed = inc ongoing.targetItemsUsed }


incItemsUsed : Who -> ItemKind.Kind -> OngoingFight -> OngoingFight
incItemsUsed who itemKind ongoing =
    addItemsUsed who itemKind 1 ongoing


itemCount : ItemKind.Kind -> Opponent -> Int
itemCount kind opponent =
    opponent.items
        |> Dict.find (\_ item -> item.kind == kind)
        |> Maybe.map (Tuple.second >> .count)
        |> Maybe.withDefault 0


moveForward : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
moveForward who ongoing =
    if ongoing.distanceHexes <= 1 then
        rejectCommand who MoveForward_AlreadyNextToEachOther ongoing

    else
        let
            opponent =
                opponent_ who ongoing

            maxPossibleMove : Int
            maxPossibleMove =
                Logic.maxPossibleMove
                    { actionPoints = opponentAp who ongoing
                    , crippledLegs = crippledLegs opponent
                    }
                    |> min (ongoing.distanceHexes - 1)

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
            |> Random.constant


skipTurn : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
skipTurn who ongoing =
    ongoing
        |> addLog who Fight.SkipTurn
        |> finalizeCommand
        |> Random.constant


chanceToHit : Who -> OngoingFight -> AttackStyle -> Int
chanceToHit who ongoing attackStyle =
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
                , equippedWeapon = otherOpponent.equippedWeapon
                , hasHthEvadePerk = Perk.rank Perk.HthEvade otherOpponent.perks > 0
                , unarmedSkill = Skill.get otherOpponent.special otherOpponent.addedSkillPercentages Skill.Unarmed
                , apFromPreviousTurn = apFromPreviousTurn other ongoing
                }
    in
    Logic.chanceToHit
        { attackerSpecial = opponent.special
        , attackerAddedSkillPercentages = opponent.addedSkillPercentages
        , attackerPerks = opponent.perks
        , attackerTraits = opponent.traits
        , attackerItems = opponent.items
        , distanceHexes = ongoing.distanceHexes
        , targetArmorClass = armorClass
        , attackStyle = attackStyle
        , equippedWeapon = opponent.equippedWeapon
        , usedAmmo = usedAmmo who ongoing
        , crippledArms = crippledArms opponent
        }


unarmedAttackStyle : ( AttackStyle, Int )
unarmedAttackStyle =
    ( AttackStyle.UnarmedUnaimed, Logic.unarmedApCost )


randomAttackStyle : Int -> Maybe ItemKind.Kind -> Generator ( AttackStyle, Int )
randomAttackStyle availableAp equippedWeapon =
    case equippedWeapon of
        Nothing ->
            Random.constant unarmedAttackStyle

        Just weapon ->
            case
                Logic.attackStyleAndApCost weapon
                    |> List.filter (\( _, apCost_ ) -> apCost_ <= availableAp)
            of
                [] ->
                    {- Either a bug where a weapon doesn't have any attack styles
                       but is equippable, or not enough AP for any attack.
                    -}
                    Random.constant unarmedAttackStyle

                x :: xs ->
                    Random.uniform x xs


attackRandomly : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attackRandomly who ongoing =
    let
        opponent : Opponent
        opponent =
            opponent_ who ongoing

        availableAp : Int
        availableAp =
            opponentAp who ongoing
    in
    randomAttackStyle availableAp opponent.equippedWeapon
        |> Random.andThen (\( attackStyle, baseApCost ) -> attack_ who ongoing attackStyle baseApCost)


attack : Who -> OngoingFight -> AttackStyle -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attack who ongoing wantedAttackStyle =
    let
        opponent =
            opponent_ who ongoing

        ( attackStyle, baseApCost ) =
            case opponent.equippedWeapon of
                Nothing ->
                    unarmedAttackStyle

                Just weapon ->
                    let
                        possibleAttackStyles : List ( AttackStyle, Int )
                        possibleAttackStyles =
                            Logic.attackStyleAndApCost weapon
                    in
                    possibleAttackStyles
                        |> List.find (\( attackStyle_, _ ) -> attackStyle_ == wantedAttackStyle)
                        |> {- TODO can this happen? Eg. when we have equipped a
                              spear but want to do Burst?  Should we let the
                              player know something weird happened?

                              This is theoretically a loophole where the player
                              has a weapon with cost of shooting 5, has 3 AP
                              left, and intentionally uses this invalid command
                              to make use of this AP remnant with an unarmed
                              attack.
                           -}
                           Maybe.withDefault unarmedAttackStyle
    in
    attack_ who ongoing attackStyle baseApCost


attack_ : Who -> OngoingFight -> AttackStyle -> Int -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
attack_ who ongoing attackStyle baseApCost =
    let
        opponent =
            opponent_ who ongoing

        other : Who
        other =
            Fight.theOther who

        apCost_ : Int
        apCost_ =
            Logic.attackApCost
                { isAimedShot = AttackStyle.isAimed attackStyle
                , hasBonusHthAttacksPerk = Perk.rank Perk.BonusHthAttacks opponent.perks > 0
                , hasBonusRateOfFirePerk = Perk.rank Perk.BonusRateOfFire opponent.perks > 0
                , attackStyle = attackStyle
                , baseApCost = baseApCost
                }

        chanceToHit_ : Int
        chanceToHit_ =
            chanceToHit who ongoing attackStyle

        weaponRange : Int
        weaponRange =
            Logic.weaponRange opponent.equippedWeapon attackStyle

        attackStats : AttackStats
        attackStats =
            Logic.attackStats
                { special = opponent.special
                , addedSkillPercentages = opponent.addedSkillPercentages
                , level = opponent.level
                , perks = opponent.perks
                , traits = opponent.traits
                , equippedWeapon = opponent.equippedWeapon
                , preferredAmmo = opponent.preferredAmmo
                , items = opponent.items
                , unarmedDamageBonus = opponent.unarmedDamageBonus
                , attackStyle = attackStyle
                , crippledArms = crippledArms opponent
                }

        criticalChance_ : Int -> Int
        criticalChance_ roll =
            let
                rollCriticalChanceBonus : Int
                rollCriticalChanceBonus =
                    (chanceToHit_ - roll) // 10

                baseCriticalChance : Int
                baseCriticalChance =
                    Logic.baseCriticalChance
                        { special = opponent.special
                        , perks = opponent.perks
                        , traits = opponent.traits
                        , attackStyle = attackStyle
                        , chanceToHit = chanceToHit_
                        , hitOrMissRoll = roll
                        }
            in
            min 100 <|
                baseCriticalChance
                    + rollCriticalChanceBonus
                    + attackStats.criticalChanceBonus

        criticalEffectCategory : Bool -> Generator (Maybe Critical.EffectCategory)
        criticalEffectCategory isCritical =
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

        continueAttack : Maybe ( Item.Id, ItemKind.Kind, Int ) -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
        continueAttack usedAmmo_ =
            let
                useAmmo n ong =
                    case usedAmmo_ of
                        Nothing ->
                            ong

                        Just ( _, ammoKind, _ ) ->
                            ong
                                |> updateOpponent who (subItem n ammoKind)
                                |> addItemsUsed who ammoKind n

                continueNonburst : Int -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
                continueNonburst roll =
                    let
                        hasHit : Bool
                        hasHit =
                            roll <= chanceToHit_
                    in
                    -- TODO critical misses according to inspiration/fo2-calc/fo2calg.pdf
                    if hasHit then
                        Random.weightedBool (toFloat (criticalChance_ roll) / 100)
                            |> Random.andThen criticalEffectCategory
                            |> Random.andThen (rollCritical who ongoing attackStyle)
                            |> Random.andThen
                                (\maybeCritical ->
                                    rollDamage who ongoing attackStyle maybeCritical
                                        |> Random.map
                                            (\damage ->
                                                let
                                                    action : Fight.Action
                                                    action =
                                                        Fight.Attack
                                                            { damage = damage
                                                            , attackStyle = attackStyle
                                                            , remainingHp = (opponent_ other ongoing).hp - damage
                                                            , critical =
                                                                maybeCritical
                                                                    |> Maybe.map (\c -> ( c.effects, c.message ))
                                                            , apCost = apCost_
                                                            }
                                                in
                                                ongoing
                                                    |> addLog who action
                                                    |> subtractAp who action
                                                    |> useAmmo 1
                                                    |> updateOpponent other (subtractHp damage)
                                                    |> (case maybeCritical of
                                                            Nothing ->
                                                                identity

                                                            Just c ->
                                                                updateOpponent other (applyCriticalEffects c.effects)
                                                       )
                                                    |> finalizeCommand
                                            )
                                )

                    else
                        let
                            action : Fight.Action
                            action =
                                Fight.Miss
                                    { attackStyle = attackStyle
                                    , apCost = apCost_
                                    }
                        in
                        ongoing
                            |> addLog who action
                            |> subtractAp who action
                            |> useAmmo 1
                            |> finalizeCommand
                            |> Random.constant

                continueBurst : Int -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
                continueBurst roll =
                    case ( usedAmmo_, opponent.equippedWeapon ) of
                        ( Nothing, _ ) ->
                            -- Weapon that uses burst but doesn't use ammo. Can't happen with our selection of weapons and is kinda weird.
                            Random.constant { ranCommandSuccessfully = False, nextOngoing = ongoing }

                        ( _, Nothing ) ->
                            -- No weapon equipped, so we can't burst fire.
                            Random.constant { ranCommandSuccessfully = False, nextOngoing = ongoing }

                        ( Just ( _, _, availableAmmo ), Just weapon ) ->
                            let
                                bulletsUsed : Int
                                bulletsUsed =
                                    -- eg. Bozar wants to use 15 bullets, and we have 50 left. Use 15.
                                    -- eg. Bozar wants to use 15 bullets, but we have 9 left. Use 9.
                                    min (ItemKind.shotsPerBurst weapon) availableAmmo

                                oneBullet : Maybe Critical -> Generator (Maybe Int)
                                oneBullet maybeCritical =
                                    Random.int 1 100
                                        |> Random.andThen
                                            (\hitRoll ->
                                                let
                                                    hasHit : Bool
                                                    hasHit =
                                                        hitRoll <= chanceToHit_
                                                in
                                                if hasHit then
                                                    rollDamage who ongoing attackStyle maybeCritical
                                                        |> Random.map Just

                                                else
                                                    Random.constant Nothing
                                            )
                            in
                            Random.weightedBool (toFloat (criticalChance_ roll) / 100)
                                |> Random.andThen criticalEffectCategory
                                |> Random.andThen (rollCritical who ongoing attackStyle)
                                |> Random.andThen
                                    (\maybeCritical ->
                                        Random.list bulletsUsed (oneBullet maybeCritical)
                                            |> Random.map
                                                (\bulletHits ->
                                                    let
                                                        damage : Int
                                                        damage =
                                                            bulletHits
                                                                |> List.filterMap identity
                                                                |> List.sum

                                                        action : Fight.Action
                                                        action =
                                                            Fight.Attack
                                                                { damage = damage
                                                                , attackStyle = attackStyle
                                                                , remainingHp = (opponent_ other ongoing).hp - damage
                                                                , critical = maybeCritical |> Maybe.map (\c -> ( c.effects, c.message ))
                                                                , apCost = apCost_
                                                                }
                                                    in
                                                    ongoing
                                                        |> addLog who action
                                                        |> subtractAp who action
                                                        |> useAmmo bulletsUsed
                                                        |> updateOpponent other (subtractHp damage)
                                                        |> (case maybeCritical of
                                                                Nothing ->
                                                                    identity

                                                                Just c ->
                                                                    updateOpponent other (applyCriticalEffects c.effects)
                                                           )
                                                        |> finalizeCommand
                                                )
                                    )
            in
            Random.int 1 100
                |> Random.andThen
                    (\roll ->
                        case attackStyle of
                            ShootBurst ->
                                continueBurst roll

                            --
                            UnarmedUnaimed ->
                                continueNonburst roll

                            UnarmedAimed _ ->
                                continueNonburst roll

                            MeleeUnaimed ->
                                continueNonburst roll

                            MeleeAimed _ ->
                                continueNonburst roll

                            Throw ->
                                continueNonburst roll

                            ShootSingleUnaimed ->
                                continueNonburst roll

                            ShootSingleAimed _ ->
                                continueNonburst roll
                    )
    in
    if ongoing.distanceHexes > weaponRange then
        rejectCommand who Attack_NotCloseEnough ongoing

    else if opponentAp who ongoing < apCost_ then
        -- We've already filtered out attack styles with more AP than you can use.
        -- If we're here it means that code has fallen through to the unarmed 3 AP default.
        rejectCommand who Attack_NotEnoughAP ongoing

    else
        case usedAmmo who ongoing of
            Logic.PreferredAmmo ammo ->
                continueAttack (Just ammo)

            Logic.FallbackAmmo ammo ->
                continueAttack (Just ammo)

            Logic.NoAmmoNeeded ->
                continueAttack Nothing

            Logic.NoUsableAmmo ->
                -- fall back to an unarmed attack
                attack_
                    who
                    (ongoing |> updateOpponent who unequipWeapon)
                    (Tuple.first unarmedAttackStyle)
                    (Tuple.second unarmedAttackStyle)


type alias StrategyState =
    { you : Opponent
    , them : Opponent
    , themWho : Who
    , yourAp : Int
    , yourItemsUsed : SeqDict ItemKind.Kind Int
    , distanceHexes : Int
    , ongoingFight : OngoingFight
    }


evalStrategy : Who -> StrategyState -> FightStrategy -> Command
evalStrategy who state strategy =
    case strategy of
        Command command ->
            command

        If { condition, then_, else_ } ->
            if evalCondition who state condition then
                evalStrategy who state then_

            else
                evalStrategy who state else_


evalCondition : Who -> StrategyState -> Condition -> Bool
evalCondition who state condition =
    case condition of
        Or c1 c2 ->
            evalCondition who state c1 || evalCondition who state c2

        And c1 c2 ->
            evalCondition who state c1 && evalCondition who state c2

        OpponentIsPlayer ->
            Fight.isPlayer state.them.type_

        OpponentIsNPC ->
            Fight.isNPC state.them.type_

        Operator { lhs, op, rhs } ->
            operatorFn
                op
                (evalValue who state lhs)
                (evalValue who state rhs)


evalValue : Who -> StrategyState -> Value -> Int
evalValue who state value =
    case value of
        MyHP ->
            state.you.hp

        MyMaxHP ->
            state.you.maxHp

        MyAP ->
            state.yourAp

        MyItemCount itemKind ->
            state.you.items
                -- TODO should we do unique key instead of just kind???
                |> Dict.find (\_ item -> item.kind == itemKind)
                |> Maybe.map (Tuple.second >> .count)
                |> Maybe.withDefault 0

        MyHealingItemCount ->
            state.you.items
                |> Dict.toList
                |> List.filterMap
                    (\( _, item ) ->
                        if ItemKind.isHealing item.kind then
                            Just item.count

                        else
                            Nothing
                    )
                |> List.sum

        MyAmmoCount ->
            case state.you.equippedWeapon of
                Nothing ->
                    0

                Just weapon ->
                    state.you.items
                        |> Dict.toList
                        |> List.filterMap
                            (\( _, item ) ->
                                if ItemKind.isUsableAmmoForWeapon weapon item.kind then
                                    Just item.count

                                else
                                    Nothing
                            )
                        |> List.sum

        ItemsUsed itemKind ->
            state.yourItemsUsed
                |> SeqDict.get itemKind
                |> Maybe.withDefault 0

        HealingItemsUsed ->
            state.yourItemsUsed
                |> SeqDict.toList
                |> List.filterMap
                    (\( kind, count ) ->
                        if ItemKind.isHealing kind then
                            Just count

                        else
                            Nothing
                    )
                |> List.sum

        AmmoUsed ->
            case state.you.equippedWeapon of
                Nothing ->
                    0

                Just weapon ->
                    state.yourItemsUsed
                        |> SeqDict.toList
                        |> List.filterMap
                            (\( kind, count ) ->
                                if ItemKind.isUsableAmmoForWeapon weapon kind then
                                    Just count

                                else
                                    Nothing
                            )
                        |> List.sum

        ChanceToHit attackStyle ->
            Logic.chanceToHit
                { attackerAddedSkillPercentages = state.you.addedSkillPercentages
                , attackerSpecial = state.you.special
                , attackerPerks = state.you.perks
                , attackerTraits = state.you.traits
                , attackerItems = state.you.items
                , distanceHexes = state.distanceHexes
                , targetArmorClass =
                    Logic.armorClass
                        { naturalArmorClass = state.them.naturalArmorClass
                        , equippedArmor = state.them.equippedArmor
                        , equippedWeapon = state.them.equippedWeapon
                        , hasHthEvadePerk = Perk.rank Perk.HthEvade state.them.perks > 0
                        , unarmedSkill = Skill.get state.them.special state.them.addedSkillPercentages Skill.Unarmed
                        , apFromPreviousTurn = apFromPreviousTurn state.themWho state.ongoingFight
                        }
                , attackStyle = attackStyle
                , equippedWeapon = state.you.equippedWeapon
                , usedAmmo = usedAmmo who state.ongoingFight
                , crippledArms = crippledArms state.you
                }

        RangeNeeded attackStyle ->
            rangeNeeded attackStyle who state

        Distance ->
            state.distanceHexes

        Number n ->
            n


usedAmmo : Who -> OngoingFight -> Logic.UsedAmmo
usedAmmo who ongoing =
    let
        opponent =
            opponent_ who ongoing
    in
    Logic.usedAmmo opponent


rangeNeeded : AttackStyle -> Who -> StrategyState -> Int
rangeNeeded attackStyle who state =
    let
        opponent : Opponent
        opponent =
            opponent_ who state.ongoingFight
    in
    case opponent.equippedWeapon of
        Nothing ->
            Logic.unarmedRange

        Just equippedWeapon ->
            case usedAmmo who state.ongoingFight of
                Logic.PreferredAmmo _ ->
                    ItemKind.range attackStyle equippedWeapon

                Logic.FallbackAmmo _ ->
                    ItemKind.range attackStyle equippedWeapon

                Logic.NoAmmoNeeded ->
                    ItemKind.range attackStyle equippedWeapon

                Logic.NoUsableAmmo ->
                    Logic.unarmedRange


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

        fightInfoForAttacker : Fight.Info
        fightInfoForAttacker =
            { attacker = r.attacker.type_
            , target = r.target.type_
            , log = []
            , result = Fight.TargetAlreadyDead
            , attackerEquipment =
                Just
                    { weapon = r.attacker.equippedWeapon
                    , armor = r.attacker.equippedArmor
                    }
            , targetEquipment =
                if Perk.rank Perk.Awareness r.attacker.perks > 0 then
                    Just
                        { weapon = r.target.equippedWeapon
                        , armor = r.target.equippedArmor
                        }

                else
                    Nothing
            }

        fightInfoForTarget : Fight.Info
        fightInfoForTarget =
            { attacker = r.attacker.type_
            , target = r.target.type_
            , log = []
            , result = Fight.TargetAlreadyDead
            , attackerEquipment =
                if Perk.rank Perk.Awareness r.target.perks > 0 then
                    Just
                        { weapon = r.attacker.equippedWeapon
                        , armor = r.attacker.equippedArmor
                        }

                else
                    Nothing
            , targetEquipment =
                Just
                    { weapon = r.target.equippedWeapon
                    , armor = r.target.equippedArmor
                    }
            }

        messageForTarget =
            YouWereAttacked
                { attacker = attackerName
                , fightInfo = fightInfoForTarget
                }

        messageForAttacker =
            YouAttacked
                { target = targetName
                , fightInfo = fightInfoForAttacker
                }
    in
    { finalAttacker = r.attacker
    , finalTarget = r.target
    , fightInfoForAttacker = fightInfoForAttacker
    , messageForTarget = messageForTarget
    , messageForAttacker = messageForAttacker
    }


applyCriticalEffects : List Critical.Effect -> Opponent -> Opponent
applyCriticalEffects effects opponent =
    List.foldl applyCriticalEffect opponent effects


applyCriticalEffect : Critical.Effect -> Opponent -> Opponent
applyCriticalEffect effect opponent =
    case effect of
        Critical.Knockout ->
            { opponent | knockedOutTurns = Logic.knockOutTurns }

        Critical.Knockdown ->
            { opponent | isKnockedDown = True }

        Critical.CrippledLeftLeg ->
            { opponent | crippledLeftLeg = True }

        Critical.CrippledRightLeg ->
            { opponent | crippledRightLeg = True }

        Critical.CrippledLeftArm ->
            { opponent | crippledLeftArm = True }

        Critical.CrippledRightArm ->
            { opponent | crippledRightArm = True }

        Critical.Blinded ->
            { opponent | special = opponent.special |> Special.set Special.Perception 1 }

        Critical.Death ->
            { opponent | hp = 0 }

        Critical.BypassArmor ->
            -- This is interpreted in the critical damage modifier calculations elsewhere
            opponent

        Critical.LoseNextTurn ->
            { opponent | losesNextTurn = True }


unequipWeapon : Opponent -> Opponent
unequipWeapon opponent =
    { opponent | equippedWeapon = Nothing }


subtractHp : Int -> Opponent -> Opponent
subtractHp hp opponent =
    { opponent | hp = max 0 <| opponent.hp - hp }


addHp : Int -> Opponent -> Opponent
addHp hp opponent =
    { opponent | hp = min opponent.maxHp <| opponent.hp + hp }


enemyOpponentGenerator : { hasFortuneFinderPerk : Bool } -> Int -> EnemyType -> Generator ( Opponent, Int )
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
                        EnemyType.hp enemyType
                in
                ( { type_ = OpponentType.Npc enemyType
                  , hp = hp
                  , maxHp = hp
                  , maxAp = EnemyType.actionPoints enemyType
                  , sequence = EnemyType.sequence enemyType
                  , traits = SeqSet.empty
                  , perks = SeqDict.empty
                  , caps = caps_
                  , items = Dict.empty
                  , drops = items
                  , -- This is used for the named unarmed attacks. Let's skip it
                    -- for enemies for now. Maybe it will make more sense for people
                    -- like Lo Pan etc.
                    level = 1
                  , equippedArmor = EnemyType.equippedArmor enemyType
                  , equippedWeapon = EnemyType.equippedWeapon enemyType
                  , preferredAmmo = EnemyType.preferredAmmo enemyType
                  , naturalArmorClass = EnemyType.naturalArmorClass enemyType
                  , addedSkillPercentages = EnemyType.addedSkillPercentages enemyType
                  , -- Enemies never have anything else than base special (no traits, perks, ...)
                    special = EnemyType.special enemyType
                  , fightStrategy = FightStrategy.doWhatever
                  , unarmedDamageBonus = EnemyType.unarmedDamageBonus enemyType
                  , knockedOutTurns = 0
                  , isKnockedDown = False
                  , crippledLeftLeg = False
                  , crippledRightLeg = False
                  , crippledLeftArm = False
                  , crippledRightArm = False
                  , losesNextTurn = False
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
        , equippedWeapon : Maybe Item
        , preferredAmmo : Maybe ItemKind.Kind
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
    in
    { type_ =
        OpponentType.Player
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
    , level = Xp.currentLevel player.xp
    , equippedArmor = player.equippedArmor |> Maybe.map .kind
    , equippedWeapon = player.equippedWeapon |> Maybe.map .kind
    , preferredAmmo = player.preferredAmmo
    , naturalArmorClass = naturalArmorClass
    , addedSkillPercentages = player.addedSkillPercentages
    , unarmedDamageBonus = 0 -- This is only used for NPC enemies
    , special = player.special
    , fightStrategy = player.fightStrategy
    , knockedOutTurns = 0
    , isKnockedDown = False
    , crippledLeftLeg = False
    , crippledRightLeg = False
    , crippledLeftArm = False
    , crippledRightArm = False
    , losesNextTurn = False
    }


boolToInt : Bool -> Int
boolToInt b =
    if b then
        1

    else
        0


crippledLegs : Opponent -> Int
crippledLegs opponent =
    boolToInt opponent.crippledLeftLeg + boolToInt opponent.crippledRightLeg


crippledArms : Opponent -> Int
crippledArms opponent =
    boolToInt opponent.crippledLeftArm + boolToInt opponent.crippledRightArm
