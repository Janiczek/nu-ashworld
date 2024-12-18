module Data.Player.SPlayer exposing
    ( addCaps
    , addHp
    , addItem
    , addItems
    , addMessage
    , addSkillPercentage
    , addXp
    , canStartProgressing
    , clearPreferredAmmo
    , decAvailablePerks
    , equipArmor
    , equipWeapon
    , healManuallyUsingTick
    , incLosses
    , incPerkRank
    , incSpecial
    , incWins
    , levelUpHereAndNow
    , payQuestRequirements
    , preferAmmo
    , readMessage
    , recalculateHp
    , refuelCar
    , removeAllMessages
    , removeCarBattery
    , removeFightMessages
    , removeItem
    , removeItems
    , removeMessage
    , setFightStrategy
    , setHp
    , setItems
    , setLocation
    , setPreferredAmmo
    , startProgressing
    , stopProgressing
    , subtractCaps
    , subtractTicks
    , tagSkill
    , tick
    , unequipArmor
    , unequipWeapon
    , updateStrengthForAdrenalineRush
    , useSkillPoints
    )

import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Map exposing (TileCoords)
import Data.Message as Message exposing (Content(..), Message)
import Data.Perk as Perk exposing (Perk)
import Data.Player exposing (SPlayer)
import Data.Quest as Quest exposing (Quest)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special
import Data.Tick as Tick exposing (TickPerIntervalCurve)
import Data.Trait as Trait
import Data.Xp as Xp
import Dict exposing (Dict)
import Dict.Extra as Dict
import Logic
import SeqDict exposing (SeqDict)
import SeqSet
import Time exposing (Posix)


addCarBattery : Int -> SPlayer -> SPlayer
addCarBattery charge player =
    { player
        | carBatteryPromile =
            player.carBatteryPromile
                |> Maybe.map (\current -> min 1000 (current + charge))
    }


removeCarBattery : Int -> SPlayer -> SPlayer
removeCarBattery used player =
    { player
        | carBatteryPromile =
            player.carBatteryPromile
                |> Maybe.map (\current -> max 0 (current - used))
    }


addTicks : Int -> SPlayer -> SPlayer
addTicks n player =
    { player | ticks = min Tick.limit <| player.ticks + n }


addHp : Int -> SPlayer -> SPlayer
addHp n player =
    let
        newHp : Int
        newHp =
            (player.hp + n)
                |> min player.maxHp
    in
    { player | hp = newHp }
        |> updateStrengthForAdrenalineRush
            { oldHp = player.hp
            , oldMaxHp = player.maxHp
            , newHp = newHp
            , newMaxHp = player.maxHp
            }


{-| TODO it feels like this will be buggy because of the SPECIAL clamping, and
drugs/armor enhancing SPECIAL or whatever.

It would be probably safer to have some kind of `effects : Set Effect` and this
`AdrenalineRushIncreasedStrength` to live there, instead of updating the live
SPECIAL?

-}
updateStrengthForAdrenalineRush :
    { oldHp : Int
    , oldMaxHp : Int
    , newHp : Int
    , newMaxHp : Int
    }
    -> SPlayer
    -> SPlayer
updateStrengthForAdrenalineRush { oldHp, oldMaxHp, newHp, newMaxHp } player =
    let
        hasAdrenalineRushPerk : Bool
        hasAdrenalineRushPerk =
            Perk.rank Perk.AdrenalineRush player.perks > 0

        oldHalfMaxHp : Int
        oldHalfMaxHp =
            oldMaxHp // 2

        newHalfMaxHp : Int
        newHalfMaxHp =
            newMaxHp // 2
    in
    if hasAdrenalineRushPerk then
        if oldHp < oldHalfMaxHp && newHp >= newHalfMaxHp then
            player
                |> decSpecial Special.Strength

        else if oldHp >= oldHalfMaxHp && newHp < newHalfMaxHp then
            player
                |> incSpecial Special.Strength

        else
            player

    else
        player


setHpAndMaxHp : { newHp : Int, newMaxHp : Int } -> SPlayer -> SPlayer
setHpAndMaxHp { newHp, newMaxHp } player =
    { player
        | hp = newHp
        , maxHp = newMaxHp
    }
        |> updateStrengthForAdrenalineRush
            { oldHp = player.hp
            , oldMaxHp = player.maxHp
            , newHp = newHp
            , newMaxHp = newMaxHp
            }


setHp : Int -> SPlayer -> SPlayer
setHp newHp player =
    let
        newHp_ =
            clamp 0 player.maxHp newHp
    in
    { player | hp = newHp_ }
        |> updateStrengthForAdrenalineRush
            { oldHp = player.hp
            , oldMaxHp = player.maxHp
            , newHp = newHp_
            , newMaxHp = player.maxHp
            }


addXp : Int -> Posix -> SPlayer -> SPlayer
addXp n currentTime player =
    let
        newXp =
            player.xp + n

        currentLevel =
            Xp.currentLevel player.xp

        newLevel =
            Xp.currentLevel newXp

        levelsDiff =
            newLevel - currentLevel
    in
    { player | xp = newXp }
        |> (if levelsDiff > 0 then
                levelUpConsequences
                    { newLevel = newLevel
                    , levelsDiff = levelsDiff
                    , currentTime = currentTime
                    }

            else
                identity
           )


addCaps : Int -> SPlayer -> SPlayer
addCaps n player =
    { player | caps = player.caps + n }


subtractCaps : Int -> SPlayer -> SPlayer
subtractCaps n player =
    { player | caps = max 0 <| player.caps - n }


incWins : SPlayer -> SPlayer
incWins player =
    { player | wins = player.wins + 1 }


incLosses : SPlayer -> SPlayer
incLosses player =
    { player | losses = player.losses + 1 }


subtractTicks : Int -> SPlayer -> SPlayer
subtractTicks n player =
    { player | ticks = max 0 (player.ticks - n) }


setLocation : TileCoords -> SPlayer -> SPlayer
setLocation tileCoords player =
    { player | location = tileCoords }


recalculateHp : SPlayer -> SPlayer
recalculateHp player =
    let
        newMaxHp =
            Logic.hitpoints
                { level = Xp.currentLevel player.xp
                , special = player.special
                , lifegiverPerkRanks = Perk.rank Perk.Lifegiver player.perks
                }

        diff =
            newMaxHp - player.maxHp

        newHp =
            -- adding maxHp: add hp too
            -- lowering maxHp: try to keep hp the same
            if diff > 0 then
                player.hp + diff

            else
                min player.hp newMaxHp
    in
    player
        -- combined together because of the Adrenaline Rush check
        |> setHpAndMaxHp { newMaxHp = newMaxHp, newHp = newHp }


addSkillPointsOnLevelup : Int -> SPlayer -> SPlayer
addSkillPointsOnLevelup levelsDiff player =
    player
        |> addSkillPoints
            (levelsDiff
                * Logic.skillPointsPerLevel
                    { hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                    , hasSkilledTrait = Trait.isSelected Trait.Skilled player.traits
                    , educatedPerkRanks = Perk.rank Perk.Educated player.perks
                    , intelligence = player.special.intelligence
                    }
            )


addPerksOnLevelup : Int -> SPlayer -> SPlayer
addPerksOnLevelup newLevel player =
    let
        hasSkilledTrait =
            Trait.isSelected Trait.Skilled player.traits

        totalPerkRanks =
            List.sum <| SeqDict.values player.perks

        perkRate =
            Logic.perkRate { hasSkilledTrait = hasSkilledTrait }

        totalAvailablePerks =
            newLevel // perkRate

        newAvailablePerks =
            totalAvailablePerks - totalPerkRanks
    in
    player
        |> setAvailablePerks newAvailablePerks


tick : Posix -> TickPerIntervalCurve -> SPlayer -> SPlayer
tick currentTime worldTickCurve player =
    player
        |> addTicks (ticksToAdd worldTickCurve player)
        |> addTickQuestProgressXp currentTime
        |> (if player.hp < player.maxHp then
                addHp
                    (Logic.healOverTimePerTick
                        { special = player.special
                        , addedSkillPercentages = player.addedSkillPercentages
                        , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                        }
                    )

            else
                identity
           )


addTickQuestProgressXp : Posix -> SPlayer -> SPlayer
addTickQuestProgressXp currentTime player =
    let
        xpPerQuest : SeqDict Quest Int
        xpPerQuest =
            player.questsActive
                |> SeqSet.toList
                |> List.map
                    (\quest ->
                        ( quest
                        , Quest.xpPerTickGiven quest * Logic.questTicksPerHour
                        )
                    )
                |> SeqDict.fromList

        totalXp : Int
        totalXp =
            xpPerQuest
                |> SeqDict.values
                |> List.sum
    in
    player
        |> addXp totalXp currentTime


healManuallyUsingTick : SPlayer -> SPlayer
healManuallyUsingTick player =
    if player.hp >= player.maxHp || player.ticks <= 0 then
        player

    else
        let
            tickHealPercentage : Int
            tickHealPercentage =
                Logic.tickHealPercentage
                    { special = player.special
                    , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                    , addedSkillPercentages = player.addedSkillPercentages
                    }
        in
        player
            |> subtractTicks 1
            |> addHp (round <| toFloat tickHealPercentage / 100 * toFloat player.maxHp)


addMessage : { read : Bool } -> Posix -> Message.Content -> SPlayer -> SPlayer
addMessage { read } currentTime messageContent player =
    let
        lastMessageId : Int
        lastMessageId =
            player.messages
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        createMessage =
            if read then
                Message.newRead

            else
                Message.new

        message : Message
        message =
            createMessage
                (lastMessageId + 1)
                currentTime
                messageContent
    in
    { player | messages = Dict.insert message.id message player.messages }


readMessage : Message.Id -> SPlayer -> SPlayer
readMessage messageIdToRead player =
    { player
        | messages =
            Dict.update
                messageIdToRead
                (Maybe.map (\message -> { message | hasBeenRead = True }))
                player.messages
    }


removeMessage : Message.Id -> SPlayer -> SPlayer
removeMessage messageIdToRemove player =
    { player | messages = Dict.remove messageIdToRemove player.messages }


removeFightMessages : SPlayer -> SPlayer
removeFightMessages player =
    { player
        | messages =
            player.messages
                |> Dict.filter (\_ message -> not (Message.isFightMessage message.content))
    }


removeAllMessages : SPlayer -> SPlayer
removeAllMessages player =
    { player | messages = Dict.empty }


addItems : List Item -> SPlayer -> SPlayer
addItems items player =
    List.foldl
        addItem
        player
        items


addItem : Item -> SPlayer -> SPlayer
addItem item player =
    let
        id =
            Item.findMergeableId item player.items
                |> Maybe.withDefault item.id
    in
    { player
        | items =
            player.items
                |> Dict.update id
                    (\maybeItem ->
                        case maybeItem of
                            Nothing ->
                                Just item

                            Just oldItem ->
                                Just { oldItem | count = oldItem.count + item.count }
                    )
    }


removeItems : List ( Item.Id, Int ) -> SPlayer -> SPlayer
removeItems items player =
    List.foldl
        (\( id, removedCount ) accPlayer -> removeItem id removedCount accPlayer)
        player
        items


removeItem : Item.Id -> Int -> SPlayer -> SPlayer
removeItem id removedCount player =
    { player
        | items =
            player.items
                |> Dict.update id
                    (Maybe.andThen
                        (\oldItem ->
                            if oldItem.count > removedCount then
                                Just { oldItem | count = oldItem.count - removedCount }

                            else
                                Nothing
                        )
                    )
    }


tagSkill : Skill -> SPlayer -> SPlayer
tagSkill skill player =
    { player | taggedSkills = SeqSet.insert skill player.taggedSkills }


useSkillPoints : Skill -> SPlayer -> SPlayer
useSkillPoints skill player =
    let
        isTagged : Bool
        isTagged =
            SeqSet.member skill player.taggedSkills

        percentToAdd : Int
        percentToAdd =
            if isTagged then
                2

            else
                1

        neededPoints : Int
        neededPoints =
            Logic.skillPointCost skillPercent

        skillPercent : Int
        skillPercent =
            Skill.get player.special player.addedSkillPercentages skill
    in
    if skillPercent < 300 && player.availableSkillPoints >= neededPoints then
        addSkillPercentage
            percentToAdd
            skill
            { player | availableSkillPoints = player.availableSkillPoints - neededPoints }

    else
        player


addSkillPercentage : Int -> Skill -> SPlayer -> SPlayer
addSkillPercentage percentToAdd skill player =
    let
        skillPercent : Int
        skillPercent =
            Skill.get player.special player.addedSkillPercentages skill
    in
    if skillPercent < 300 then
        { player
            | addedSkillPercentages =
                SeqDict.update skill
                    (\maybePercent ->
                        case maybePercent of
                            Nothing ->
                                Just percentToAdd

                            Just percent ->
                                Just <| percent + percentToAdd
                    )
                    player.addedSkillPercentages
        }

    else
        player


addSkillPoints : Int -> SPlayer -> SPlayer
addSkillPoints points player =
    { player | availableSkillPoints = player.availableSkillPoints + points }


setAvailablePerks : Int -> SPlayer -> SPlayer
setAvailablePerks perks player =
    { player | availablePerks = perks }


decAvailablePerks : SPlayer -> SPlayer
decAvailablePerks player =
    { player | availablePerks = max 0 <| player.availablePerks - 1 }


incPerkRank : Perk -> SPlayer -> SPlayer
incPerkRank perk player =
    { player
        | perks =
            SeqDict.update perk
                (\maybeRank ->
                    case maybeRank of
                        Nothing ->
                            Just 1

                        Just n ->
                            Just <| n + 1
                )
                player.perks
    }


levelUpHereAndNow : Posix -> SPlayer -> SPlayer
levelUpHereAndNow currentTime player =
    let
        nextXp =
            Xp.nextLevelXp player.xp

        newLevel =
            Xp.currentLevel nextXp
    in
    { player | xp = nextXp }
        |> levelUpConsequences
            { newLevel = newLevel
            , levelsDiff = 1
            , currentTime = currentTime
            }


levelUpConsequences :
    { newLevel : Int
    , levelsDiff : Int
    , currentTime : Posix
    }
    -> SPlayer
    -> SPlayer
levelUpConsequences { newLevel, levelsDiff, currentTime } =
    recalculateHp
        >> addSkillPointsOnLevelup levelsDiff
        >> addPerksOnLevelup newLevel
        >> addMessage { read = False } currentTime (YouAdvancedLevel { newLevel = newLevel })


incSpecial : Special.Type -> SPlayer -> SPlayer
incSpecial specialType player =
    { player | special = Special.increment specialType player.special }
        |> recalculateHp


decSpecial : Special.Type -> SPlayer -> SPlayer
decSpecial specialType player =
    { player | special = Special.decrement specialType player.special }
        |> recalculateHp


unequipArmor : SPlayer -> SPlayer
unequipArmor player =
    case player.equippedArmor of
        Nothing ->
            player

        Just armor ->
            { player | equippedArmor = Nothing }
                |> addItem armor


unequipWeapon : SPlayer -> SPlayer
unequipWeapon player =
    case player.equippedWeapon of
        Nothing ->
            player

        Just weapon ->
            { player
                | equippedWeapon = Nothing
                , preferredAmmo = Nothing
            }
                |> addItem weapon


clearPreferredAmmo : SPlayer -> SPlayer
clearPreferredAmmo player =
    case player.preferredAmmo of
        Nothing ->
            player

        Just _ ->
            { player | preferredAmmo = Nothing }


equipArmor : Item -> SPlayer -> SPlayer
equipArmor { id } player =
    -- just to be sure...
    case Dict.get id player.items of
        Nothing ->
            player

        Just item ->
            if ItemKind.isArmor item.kind then
                player
                    |> (if player.equippedArmor /= Nothing then
                            unequipArmor

                        else
                            identity
                       )
                    |> removeItem item.id 1
                    |> (\p -> { p | equippedArmor = Just { item | count = 1 } })

            else
                player


equipWeapon : Item -> SPlayer -> SPlayer
equipWeapon { id } player =
    -- just to be sure...
    case Dict.get id player.items of
        Nothing ->
            player

        Just item ->
            if ItemKind.isWeapon item.kind then
                player
                    |> (if player.equippedWeapon /= Nothing then
                            unequipWeapon

                        else
                            identity
                       )
                    |> removeItem item.id 1
                    |> (\p -> { p | equippedWeapon = Just { item | count = 1 } })

            else
                player


preferAmmo : ItemKind.Kind -> SPlayer -> SPlayer
preferAmmo itemKind player =
    if ItemKind.isAmmo itemKind then
        { player | preferredAmmo = Just itemKind }

    else
        player


setFightStrategy : ( FightStrategy, String ) -> SPlayer -> SPlayer
setFightStrategy ( strategy, text ) player =
    { player
        | fightStrategy = strategy
        , fightStrategyText = text
    }


setItems : Dict Item.Id Item -> SPlayer -> SPlayer
setItems items player =
    { player | items = items }


setPreferredAmmo : Maybe ItemKind.Kind -> SPlayer -> SPlayer
setPreferredAmmo preferredAmmo player =
    { player | preferredAmmo = preferredAmmo }


stopProgressing : Quest -> SPlayer -> SPlayer
stopProgressing quest player =
    { player | questsActive = SeqSet.remove quest player.questsActive }


canStartProgressing : TickPerIntervalCurve -> SPlayer -> Bool
canStartProgressing worldTickCurve player =
    (Tick.worstCaseScenarioTicksForQuests worldTickCurve - ticksPerHourUsedOnQuests player)
        >= Logic.questTicksPerHour


startProgressing : Quest -> TickPerIntervalCurve -> SPlayer -> SPlayer
startProgressing quest worldTickCurve player =
    if canStartProgressing worldTickCurve player then
        { player | questsActive = SeqSet.insert quest player.questsActive }

    else
        player


ticksPerHourUsedOnQuests : SPlayer -> Int
ticksPerHourUsedOnQuests player =
    player.questsActive
        |> SeqSet.size
        |> (*) Logic.questTicksPerHour


ticksToAdd : TickPerIntervalCurve -> SPlayer -> Int
ticksToAdd worldTickCurve player =
    Tick.ticksAddedPerInterval worldTickCurve player.ticks - ticksPerHourUsedOnQuests player


payQuestRequirements : List Quest.PlayerRequirement -> SPlayer -> SPlayer
payQuestRequirements reqs player =
    List.foldl
        (\req accPlayer ->
            case req of
                Quest.SkillRequirement _ ->
                    accPlayer

                Quest.ItemRequirementOneOf requiredItems ->
                    -- Only pay the first item you find
                    case Dict.find (\_ item -> List.member item.kind requiredItems && item.count >= 1) accPlayer.items of
                        Nothing ->
                            accPlayer

                        Just ( id, item ) ->
                            { accPlayer
                                | items =
                                    if item.count == 1 then
                                        Dict.remove id accPlayer.items

                                    else
                                        Dict.insert id { item | count = max 0 (item.count - 1) } accPlayer.items
                            }

                Quest.CapsRequirement capsRequired ->
                    -- It should have been checked outside this function that we _do_ have enough caps to pay
                    { accPlayer | caps = max 0 (player.caps - capsRequired) }
        )
        player
        reqs


refuelCar : ItemKind.Kind -> SPlayer -> SPlayer
refuelCar fuelKind player =
    let
        fuelItem : Maybe ( Item.Id, Item )
        fuelItem =
            -- TODO this could be a helper somewhere.
            player.items
                |> Dict.find (\_ item -> item.kind == fuelKind)
    in
    case fuelItem of
        Nothing ->
            player

        Just ( itemId, item ) ->
            if item.count > 0 then
                case ItemKind.carBatteryChargePromileAmount fuelKind of
                    Nothing ->
                        player

                    Just fuelCharge ->
                        player
                            |> removeItem itemId 1
                            |> addCarBattery fuelCharge

            else
                player
