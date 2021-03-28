module Logic exposing
    ( actionPoints
    , affectsHitpoints
    , armourClass
    , healingRate
    , hitpoints
    , meleeChanceToHit
    , sequence
    , xpGained
    )

import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.Special
    exposing
        ( Special
        , SpecialType(..)
        )


affectsHitpoints : SpecialType -> Bool
affectsHitpoints type_ =
    case type_ of
        Strength ->
            True

        Endurance ->
            True

        _ ->
            False


hitpoints :
    { level : Int
    , special : Special
    }
    -> Int
hitpoints { level, special } =
    let
        { strength, endurance } =
            special
    in
    15
        + (2 * endurance)
        + strength
        + (level * (2 + endurance // 2))


healingRate : Special -> Int
healingRate { endurance } =
    tickHealingRateMultiplier
        * max 1 (endurance // 3)


tickHealingRateMultiplier : Int
tickHealingRateMultiplier =
    2


armourClass : Special -> Int
armourClass { agility } =
    -- TODO take armour into account once we have it
    agility


actionPoints : Special -> Int
actionPoints { agility } =
    5 + agility // 2


distancePenalty : Int -> Int
distancePenalty distanceHexes =
    distanceHexes * 4


darknessPenalty : Bool -> Int -> Int
darknessPenalty isItDark distanceHexes =
    if isItDark then
        if distanceHexes <= 0 then
            0

        else if distanceHexes == 1 then
            10

        else if distanceHexes == 2 then
            25

        else
            -- 3+
            40

    else
        0


meleeChanceToHit :
    { attackerSpecial : Special
    , targetSpecial : Special
    , isItDark : Bool
    , distanceHexes : Int
    , shotType : ShotType
    }
    -> Int
meleeChanceToHit r =
    if r.distanceHexes > 0 then
        0

    else
        let
            skillPercentage : Int
            skillPercentage =
                -- TODO choose between unarmed and melee. Right now, having no inventory, we choose unarmed
                -- TODO take this from the skills record in the SPlayer once we have it. Right now we compute the initial value
                30 + 2 * (r.attackerSpecial.strength + r.attackerSpecial.agility)

            shotPenalty : Int
            shotPenalty =
                ShotType.penalty r.shotType
        in
        (skillPercentage
            - armourClass r.targetSpecial
            - shotPenalty
            {- Those two never matter for unarmed fights right now, but let's
               keep them in case we later tweak the two functions to do something
               when distance = 0:
            -}
            - distancePenalty r.distanceHexes
            - darknessPenalty r.isItDark r.distanceHexes
        )
            |> clamp 0 95


sequence :
    { perception : Int
    , hasKamikazePerk : Bool
    , earlierSequencePerkCount : Int
    }
    -> Int
sequence { perception, hasKamikazePerk, earlierSequencePerkCount } =
    let
        base =
            2 * perception

        kamikazeBonus =
            if hasKamikazePerk then
                5

            else
                0

        earlierSequenceBonus =
            earlierSequencePerkCount * 2
    in
    base
        + kamikazeBonus
        + earlierSequenceBonus


xpPerHpMultiplier : Int
xpPerHpMultiplier =
    10


xpGained : { damageDealt : Int } -> Int
xpGained { damageDealt } =
    damageDealt * xpPerHpMultiplier
