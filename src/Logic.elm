module Logic exposing
    ( actionPoints
    , healingRate
    , hitpoints
    , sequence
    , unarmedAttackStats
    , unarmedChanceToHit
    , xpGained
    )

import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.Special
    exposing
        ( Special
        , SpecialType(..)
        )


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


temporaryUnarmedSkill : Special -> Int
temporaryUnarmedSkill { strength, agility } =
    -- TODO this is just the initial value
    -- TODO remove this and use the value from SPlayer once we start tracking it there
    30 + 2 * (strength + agility)


unarmedChanceToHit :
    { attackerSpecial : Special
    , targetSpecial : Special
    , distanceHexes : Int
    , shotType : ShotType
    }
    -> Int
unarmedChanceToHit r =
    let
        -- TODO vary the nighttime
        isItDark =
            False
    in
    -- TODO choose between unarmed and melee. Right now, having no inventory, we choose unarmed
    if r.distanceHexes > 0 then
        0

    else
        let
            skillPercentage : Int
            skillPercentage =
                temporaryUnarmedSkill r.attackerSpecial

            shotPenalty : Int
            shotPenalty =
                ShotType.chanceToHitPenalty r.shotType
        in
        (skillPercentage
            - armourClass r.targetSpecial
            - shotPenalty
            {- Those two never matter for unarmed fights right now, but let's
               keep them in case we later tweak the two functions to do something
               when distance = 0:
            -}
            - distancePenalty r.distanceHexes
            - darknessPenalty isItDark r.distanceHexes
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


unarmedAttackStats :
    { special : Special
    , level : Int
    }
    ->
        { minDamage : Int
        , maxDamage : Int
        , criticalChanceBonus : Int
        }
unarmedAttackStats { special, level } =
    let
        { strength, agility } =
            special

        unarmedSkill : Int
        unarmedSkill =
            temporaryUnarmedSkill special

        heavyHandedTraitBonus : Int
        heavyHandedTraitBonus =
            -- TODO
            0

        hthDamagePerkBonus : Int
        hthDamagePerkBonus =
            -- TODO
            0

        bonusMeleeDamage : Int
        bonusMeleeDamage =
            max 1 (strength - 5) + heavyHandedTraitBonus + hthDamagePerkBonus

        { unarmedAttackBonus, criticalChanceBonus } =
            if unarmedSkill < 55 || agility < 6 then
                { unarmedAttackBonus = 0
                , criticalChanceBonus = 0
                }

            else if unarmedSkill < 75 || strength < 5 || level < 6 then
                { unarmedAttackBonus = 3
                , criticalChanceBonus = 0
                }

            else if unarmedSkill < 100 || agility < 7 || level < 9 then
                { unarmedAttackBonus = 5
                , criticalChanceBonus = 5
                }

            else
                { unarmedAttackBonus = 7
                , criticalChanceBonus = 15
                }

        minDamage : Int
        minDamage =
            1 + unarmedAttackBonus

        maxDamage : Int
        maxDamage =
            1 + unarmedAttackBonus + bonusMeleeDamage
    in
    -- TODO refactor this into the attacks (Punch, StrongPunch, ...)
    -- TODO return a list of possible attacks
    -- TODO track their AP cost too
    { minDamage = minDamage
    , maxDamage = maxDamage
    , criticalChanceBonus = criticalChanceBonus
    }
