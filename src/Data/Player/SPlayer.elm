module Data.Player.SPlayer exposing
    ( addCaps
    , addHp
    , addItem
    , addMessage
    , addSkillPercentage
    , addXp
    , decAvailablePerks
    , equipItem
    , healUsingTick
    , incLosses
    , incPerkRank
    , incSpecial
    , incWins
    , levelUpHereAndNow
    , readMessage
    , removeItem
    , removeMessage
    , setHp
    , setLocation
    , subtractCaps
    , subtractTicks
    , tagSkill
    , tick
    , unequipArmor
    , updateStrengthForAdrenalineRush
    , useSkillPoints
    )

import AssocList as Dict_
import AssocSet as Set_
import Data.Item as Item exposing (Item)
import Data.Map exposing (TileNum)
import Data.Message as Message exposing (Message, Type(..))
import Data.Perk as Perk exposing (Perk)
import Data.Player exposing (SPlayer)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special
import Data.Tick as Tick
import Data.Trait as Trait
import Data.Xp as Xp
import Dict
import Logic
import Time exposing (Posix)


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


setMaxHp : Int -> SPlayer -> SPlayer
setMaxHp newMaxHp player =
    { player | maxHp = newMaxHp }
        |> updateStrengthForAdrenalineRush
            { oldHp = player.hp
            , oldMaxHp = player.maxHp
            , newHp = player.hp
            , newMaxHp = newMaxHp
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


setLocation : TileNum -> SPlayer -> SPlayer
setLocation tileNum player =
    { player | location = tileNum }


recalculateHp : SPlayer -> SPlayer
recalculateHp player =
    let
        newMaxHp =
            Logic.hitpoints
                { level = Xp.currentLevel player.xp
                , special = player.special
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
            List.sum <| Dict_.values player.perks

        perkRate =
            Logic.perkRate { hasSkilledTrait = hasSkilledTrait }

        totalAvailablePerks =
            newLevel // perkRate

        newAvailablePerks =
            totalAvailablePerks - totalPerkRanks
    in
    player
        |> setAvailablePerks newAvailablePerks


tick : SPlayer -> SPlayer
tick player =
    player
        |> addTicks (Tick.ticksAddedPerInterval player.ticks)
        |> (if player.hp < player.maxHp then
                -- Logic.healingRate already accounts for tick healing rate multiplier
                addHp Logic.healPerTick

            else
                identity
           )


healUsingTick : SPlayer -> SPlayer
healUsingTick player =
    if player.hp >= player.maxHp || player.ticks <= 0 then
        player

    else
        let
            tickHealPercentage : Int
            tickHealPercentage =
                Logic.tickHealPercentage
                    { endurance = player.special.endurance
                    , fasterHealingPerkRanks = Perk.rank Perk.FasterHealing player.perks
                    }
        in
        player
            |> subtractTicks 1
            |> addHp (round <| toFloat tickHealPercentage / 100 * toFloat player.maxHp)


addMessage : Message -> SPlayer -> SPlayer
addMessage message player =
    { player | messages = message :: player.messages }


readMessage : Message -> SPlayer -> SPlayer
readMessage messageToRead player =
    { player
        | messages =
            List.map
                (\message ->
                    if message == messageToRead then
                        { message | hasBeenRead = True }

                    else
                        message
                )
                player.messages
    }


removeMessage : Message -> SPlayer -> SPlayer
removeMessage messageToRemove player =
    { player | messages = List.filter ((/=) messageToRemove) player.messages }


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


removeItem : Item.Id -> Int -> SPlayer -> SPlayer
removeItem id removedCount player =
    { player
        | items =
            player.items
                |> Dict.update id
                    (\maybeItem ->
                        case maybeItem of
                            Nothing ->
                                Nothing

                            Just oldItem ->
                                if oldItem.count > removedCount then
                                    Just { oldItem | count = oldItem.count - removedCount }

                                else
                                    Nothing
                    )
    }


tagSkill : Skill -> SPlayer -> SPlayer
tagSkill skill player =
    { player | taggedSkills = Set_.insert skill player.taggedSkills }


useSkillPoints : Skill -> SPlayer -> SPlayer
useSkillPoints skill player =
    let
        isTagged : Bool
        isTagged =
            Set_.member skill player.taggedSkills

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
                Dict_.update skill
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
            Dict_.update perk
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
        >> addMessage
            (Message.new
                currentTime
                (YouAdvancedLevel { newLevel = newLevel })
            )


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


equipItem : Item -> SPlayer -> SPlayer
equipItem { id } player =
    -- just to be sure...
    case Dict.get id player.items of
        Nothing ->
            player

        Just item ->
            case Item.equippableType item.kind of
                Nothing ->
                    player

                Just Item.Armor ->
                    player
                        |> (if player.equippedArmor /= Nothing then
                                unequipArmor

                            else
                                identity
                           )
                        |> removeItem item.id 1
                        |> (\p -> { p | equippedArmor = Just { item | count = 1 } })
