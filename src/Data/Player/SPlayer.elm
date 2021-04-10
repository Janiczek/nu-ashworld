module Data.Player.SPlayer exposing
    ( addCaps
    , addItem
    , addMessage
    , addXp
    , decAvailableSpecial
    , healUsingTick
    , incLosses
    , incSpecial
    , incWins
    , readMessage
    , recalculateHp
    , removeMessage
    , setLocation
    , subtractCaps
    , subtractHp
    , subtractTicks
    , tick
    )

import Data.Item as Item exposing (Item)
import Data.Map exposing (TileNum)
import Data.Message as Message exposing (Message, Type(..))
import Data.Player exposing (SPlayer)
import Data.Special as Special exposing (SpecialType)
import Data.Tick as Tick
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


subtractHp : Int -> SPlayer -> SPlayer
subtractHp n player =
    { player | hp = (player.hp - n) |> max 0 }


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
                -- TODO later add skill points, perks, etc.
                recalculateHp
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


incSpecial : SpecialType -> SPlayer -> SPlayer
incSpecial type_ player =
    { player | special = Special.increment type_ player.special }


subtractTicks : Int -> SPlayer -> SPlayer
subtractTicks n player =
    { player | ticks = max 0 (player.ticks - n) }


decAvailableSpecial : SPlayer -> SPlayer
decAvailableSpecial player =
    { player | availableSpecial = player.availableSpecial - 1 }


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
        |> setMaxHp newMaxHp
        |> setHp newHp


tick : SPlayer -> SPlayer
tick player =
    player
        |> addTicks Tick.ticksAddedPerInterval
        |> (if player.hp < player.maxHp then
                -- Logic.healingRate already accounts for tick healing rate multiplier
                addHp (Logic.healingRate player.special)

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


addItem : Item.Id -> Item -> SPlayer -> SPlayer
addItem id item player =
    { player | items = Dict.insert id item player.items }
