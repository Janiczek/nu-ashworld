module Data.Player.SPlayer exposing
    ( addCaps
    , addHp
    , addTicks
    , addXp
    , decAvailableSpecial
    , incLosses
    , incSpecial
    , incWins
    , recalculateHp
    , setHp
    , setLocation
    , setMaxHp
    , subtractCaps
    , subtractHp
    , subtractTicks
    )

import Data.Map exposing (TileNum)
import Data.Player exposing (SPlayer)
import Data.Special as Special exposing (SpecialType)
import Data.Xp as Xp
import Logic


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


addXp : Int -> SPlayer -> SPlayer
addXp n player =
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
        |> (if Debug.log "diff" levelsDiff > 0 then
                -- TODO later add skill points, perks, etc.
                recalculateHp

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
                |> Debug.log "new max hp"

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
