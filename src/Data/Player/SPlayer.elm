module Data.Player.SPlayer exposing
    ( addCaps
    , addHp
    , addItem
    , addMessage
    , addXp
    , decAvailablePerks
    , healUsingTick
    , incLosses
    , incPerkRank
    , incSkill
    , incWins
    , readMessage
    , removeItem
    , removeMessage
    , setHp
    , setLocation
    , subtractCaps
    , subtractTicks
    , tagSkill
    , tick
    )

import AssocList as Dict_
import AssocSet as Set_
import Data.Item as Item exposing (Item)
import Data.Map exposing (TileNum)
import Data.Message as Message exposing (Message, Type(..))
import Data.Perk as Perk exposing (Perk)
import Data.Player exposing (SPlayer)
import Data.Skill as Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Tick as Tick
import Data.Trait as Trait
import Data.Xp as Xp
import Dict
import Logic
import Time exposing (Posix)


addTicks : Int -> SPlayer -> SPlayer
addTicks n player =
    { player | ticks = player.ticks + n }


addHp : Int -> SPlayer -> SPlayer
addHp n player =
    { player | hp = (player.hp + n) |> min player.maxHp }


setHp : Int -> SPlayer -> SPlayer
setHp newHp player =
    { player | hp = clamp 0 player.maxHp newHp }


setMaxHp : Int -> SPlayer -> SPlayer
setMaxHp newMaxHp player =
    { player | maxHp = newMaxHp }


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
                recalculateHpOnLevelup
                    >> addSkillPointsOnLevelup levelsDiff
                    >> addPerksOnLevelup newLevel
                    >> addMessage
                        (Message.new
                            currentTime
                            (YouAdvancedLevel { newLevel = newLevel })
                        )

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


recalculateHpOnLevelup : SPlayer -> SPlayer
recalculateHpOnLevelup player =
    let
        newMaxHp =
            Logic.hitpoints
                { level = Xp.currentLevel player.xp
                , finalSpecial =
                    Logic.special
                        { baseSpecial = player.baseSpecial
                        , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                        , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                        , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                        , isNewChar = False
                        }
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
        |> setMaxHp newMaxHp
        |> setHp newHp


addSkillPointsOnLevelup : Int -> SPlayer -> SPlayer
addSkillPointsOnLevelup levelsDiff player =
    let
        special : Special
        special =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }
    in
    player
        |> addSkillPoints
            (levelsDiff
                * Logic.skillPointsPerLevel
                    { hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                    , hasSkilledTrait = Trait.isSelected Trait.Skilled player.traits
                    , educatedPerkRanks = Perk.rank Perk.Educated player.perks
                    , intelligence = special.intelligence
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
                addHp
                    (Logic.healingRate
                        (Logic.special
                            { baseSpecial = player.baseSpecial
                            , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                            , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                            , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                            , isNewChar = False
                            }
                        )
                    )

            else
                identity
           )


healUsingTick : SPlayer -> SPlayer
healUsingTick player =
    if player.hp >= player.maxHp || player.ticks <= 0 then
        player

    else
        player
            |> subtractTicks 1
            |> setHp player.maxHp


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


incSkill : Skill -> SPlayer -> SPlayer
incSkill skill player =
    let
        isTagged : Bool
        isTagged =
            Set_.member skill player.taggedSkills

        special : Special
        special =
            Logic.special
                { baseSpecial = player.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser player.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted player.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame player.traits
                , isNewChar = False
                }

        skillPercent : Int
        skillPercent =
            Skill.get special player.addedSkillPercentages skill

        neededPoints : Int
        neededPoints =
            Logic.skillPointCost skillPercent

        percentToAdd : Int
        percentToAdd =
            if isTagged then
                2

            else
                1
    in
    if skillPercent < 300 && player.availableSkillPoints >= neededPoints then
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
            , availableSkillPoints = player.availableSkillPoints - neededPoints
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
