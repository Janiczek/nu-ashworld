module Data.Fight.Generator exposing
    ( Fight
    , enemyOpponentGenerator
    , generator
    , playerOpponent
    , targetAlreadyDead
    )

import Data.Enemy as Enemy exposing (addedSkillPercentages)
import Data.Fight as Fight exposing (CommandRejectionReason(..), Opponent, Who(..))
import Data.Fight.AimedShot as AimedShot exposing (AimedShot)
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle)
import Data.Fight.Critical as Critical exposing (Critical)
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
import Svg.Attributes exposing (x)
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
    -- TODO TODO TODO TODO check everywhere that distance is 1, not 0
    -- THEN go read through the melee combat and make sure no extra penalties are happening
    -- THEN still in melee combat, make sure ranges are taken into account: super sledge can hit from 2 hexes away but knives / unarmed needs 1 hex, etc.
    -- THEN you can probably go for ranged combat.
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


rollDamageAndCriticalInfo : Who -> OngoingFight -> AttackStyle -> Maybe Critical.EffectCategory -> Generator ( Int, Maybe ( List Critical.Effect, String ) )
rollDamageAndCriticalInfo who ongoing attackStyle maybeCriticalEffectCategory =
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
                                AttackStyle.toAimed attackStyle
                                    |> Maybe.withDefault AimedShot.Torso
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


healWithAnything : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
healWithAnything who ongoing =
    let
        opponent =
            opponent_ who ongoing
    in
    if opponent.hp == opponent.maxHp then
        rejectCommand who Fight.HealWithAnything_AlreadyFullyHealed ongoing

    else
        case Dict.find (\_ item -> Item.isHealing item.kind) opponent.items of
            Nothing ->
                rejectCommand who HealWithAnything_NoHealingItem ongoing

            Just ( _, healingItem ) ->
                heal who ongoing healingItem.kind


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
    if ongoing.distanceHexes <= 1 then
        rejectCommand who MoveForward_AlreadyNextToEachOther ongoing

    else
        -- TODO based on equipped weapon choose whether you need to move nearer to the opponent or whether it's good enough now
        -- Eg. unarmed needs distance 1
        -- Melee might need distance <=2 and might prefer distance 1
        -- Small guns might need distance <=35 and prefer the largest where the chance to hit is ~95% or something
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


skipTurn : Who -> OngoingFight -> Generator { ranCommandSuccessfully : Bool, nextOngoing : OngoingFight }
skipTurn who ongoing =
    let
        nextOngoing =
            ongoing
                |> addLog who Fight.SkipTurn
    in
    finalizeCommand nextOngoing


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
                , hasHthEvadePerk = Perk.rank Perk.HthEvade otherOpponent.perks > 0
                , unarmedSkill = Skill.get otherOpponent.special otherOpponent.addedSkillPercentages Skill.Unarmed
                , apFromPreviousTurn = apFromPreviousTurn other ongoing
                }
    in
    Logic.chanceToHit
        { attackerSpecial = opponent.special
        , attackerAddedSkillPercentages = opponent.addedSkillPercentages
        , attackerPerks = opponent.perks
        , distanceHexes = ongoing.distanceHexes
        , targetArmorClass = armorClass
        , attackStyle = attackStyle
        , equippedWeapon = opponent.equippedWeapon
        , equippedAmmo = opponent.equippedAmmo
        }


unarmedAttackStyle : ( AttackStyle, Int )
unarmedAttackStyle =
    ( AttackStyle.UnarmedUnaimed, Logic.unarmedApCost )


randomAttackStyle : Int -> Maybe Item.Kind -> Generator ( AttackStyle, Int )
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
    in
    (case opponent.equippedWeapon of
        Nothing ->
            Random.constant unarmedAttackStyle

        Just weapon ->
            let
                possibleAttackStyles : List ( AttackStyle, Int )
                possibleAttackStyles =
                    Logic.attackStyleAndApCost weapon
            in
            if
                List.member wantedAttackStyle
                    (List.map Tuple.first possibleAttackStyles)
            then
                {- TODO can this happen? Eg. when we have equipped a
                   spear but want to do Burst?  Should we let the
                   player know something weird happened?

                   This is theoretically a loophole where the player
                   has a weapon with cost of shooting 5, has 3 AP
                   left, and intentionally uses this invalid command
                   to make use of this AP remnant with an unarmed
                   attack.
                -}
                Random.constant unarmedAttackStyle

            else
                case possibleAttackStyles of
                    [] ->
                        -- This can probably only happpen if we somehow allow user to equip a non-weapon?
                        Random.constant unarmedAttackStyle

                    x :: xs ->
                        Random.uniform x xs
    )
        |> Random.andThen
            (\( attackStyle, baseApCost ) ->
                attack_ who ongoing attackStyle baseApCost
            )


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

        chance : Int
        chance =
            chanceToHit who ongoing attackStyle
    in
    if ongoing.distanceHexes /= 0 then
        rejectCommand who Attack_NotCloseEnough ongoing

    else if opponentAp who ongoing < apCost_ then
        -- We've already filtered out attack styles with more AP than you can use.
        -- If we're here it means that code has fallen through to the unarmed 3 AP default.
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
                                        |> Random.andThen (rollDamageAndCriticalInfo who ongoing attackStyle)
                                        |> Random.andThen
                                            (\( damage, maybeCriticalEffectsAndMessage ) ->
                                                let
                                                    action : Fight.Action
                                                    action =
                                                        Fight.Attack
                                                            { damage = damage
                                                            , attackStyle = attackStyle
                                                            , remainingHp = .hp (opponent_ other ongoing) - damage
                                                            , isCritical = maybeCriticalEffectsAndMessage /= Nothing
                                                            , apCost = apCost_
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
                                Fight.Miss
                                    { attackStyle = attackStyle
                                    , apCost = apCost_
                                    }
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
                        if Item.isHealing item.kind then
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
                        if Item.isHealing kind then
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
                , distanceHexes = state.distanceHexes
                , targetArmorClass =
                    Logic.armorClass
                        { naturalArmorClass = state.them.naturalArmorClass
                        , equippedArmor = state.them.equippedArmor
                        , hasHthEvadePerk = Perk.rank Perk.HthEvade state.them.perks > 0
                        , unarmedSkill = Skill.get state.them.special state.them.addedSkillPercentages Skill.Unarmed
                        , apFromPreviousTurn = apFromPreviousTurn state.themWho state.ongoingFight
                        }
                , attackStyle = attackStyle
                , equippedWeapon = state.you.equippedWeapon
                , equippedAmmo = state.you.equippedAmmo
                }

        RangeNeeded attackStyle ->
            rangeNeeded attackStyle who state

        Distance ->
            state.distanceHexes

        Number n ->
            n


rangeNeeded : AttackStyle -> Who -> StrategyState -> Int
rangeNeeded attackStyle who state =
    let
        opponent : Opponent
        opponent =
            opponent_ who state.ongoingFight

        equippedWeapon : Maybe Item.Kind
        equippedWeapon =
            opponent.equippedWeapon
    in
    equippedWeapon
        |> Maybe.map (Item.range attackStyle)
        |> Maybe.withDefault Logic.unarmedRange


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
                  , equippedWeapon = Enemy.equippedWeapon enemyType
                  , equippedAmmo = Enemy.equippedAmmo enemyType
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
        , equippedWeapon : Maybe Item
        , equippedAmmo : Maybe Item
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
    , equippedWeapon = player.equippedWeapon |> Maybe.map .kind
    , equippedAmmo = player.equippedAmmo |> Maybe.map .kind
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
