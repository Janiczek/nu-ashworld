module Data.Player.SPlayer exposing
    ( addCaps
    , addHp
    , addTicks
    , addXp
    , decAvailableSpecial
    , incLosses
    , incSpecial
    , incWins
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
import Set exposing (Set)


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
    { player | xp = player.xp + n }


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
