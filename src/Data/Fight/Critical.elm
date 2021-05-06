module Data.Fight.Critical exposing
    ( Critical
    , Effect(..)
    , EffectCategory(..)
    , Spec
    , toCategory
    )

import Data.Special as Special


type EffectCategory
    = Effect1
    | Effect2
    | Effect3
    | Effect4
    | Effect5
    | Effect6


toCategory : Int -> EffectCategory
toCategory effect =
    if effect <= 20 then
        Effect1

    else if effect <= 45 then
        Effect2

    else if effect <= 70 then
        Effect3

    else if effect <= 90 then
        Effect4

    else if effect <= 100 then
        Effect5

    else
        -- 101+
        Effect6


type Effect
    = Knockout
    | Knockdown
    | CrippledLeftLeg
    | CrippledRightLeg
    | CrippledLeftArm
    | CrippledRightArm
    | Blinded
    | Death
    | BypassArmor
    | LoseNextTurn


type alias Spec =
    { damageMultiplier : Int
    , effects : List Effect
    , message : String
    , statCheck :
        Maybe
            { stat : Special.Type
            , modifier : Int
            , failureEffect : Effect
            , failureMessage : String
            }
    }


type alias Critical =
    -- = rolled spec
    { damageMultiplier : Int

    -- effects and message are _after_  the stat check
    , effects : List Effect
    , message : String
    }
