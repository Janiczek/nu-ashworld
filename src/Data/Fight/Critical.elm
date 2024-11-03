module Data.Fight.Critical exposing
    ( Critical
    , Effect(..)
    , EffectCategory(..)
    , Message(..)
    , Spec
    , effectCodec
    , messageCodec
    , toCategory
    )

import Codec exposing (Codec)
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


type Message
    = PlayerMessage { you : String, them : String }
    | OtherMessage String


type alias Spec =
    { damageMultiplier : Int
    , effects : List Effect
    , message : Message
    , statCheck :
        Maybe
            { stat : Special.Type
            , modifier : Int
            , failureEffect : Effect
            , failureMessage : Message
            }
    }


type alias Critical =
    -- = rolled spec
    { damageMultiplier : Int

    -- effects and message are _after_  the stat check
    , effects : List Effect
    , message : Message
    }


messageCodec : Codec Message
messageCodec =
    Codec.custom
        (\playerMessageEncoder otherMessageEncoder value ->
            case value of
                PlayerMessage arg0 ->
                    playerMessageEncoder arg0

                OtherMessage arg0 ->
                    otherMessageEncoder arg0
        )
        |> Codec.variant1
            "PlayerMessage"
            PlayerMessage
            (Codec.object (\you them -> { you = you, them = them })
                |> Codec.field "you" .you Codec.string
                |> Codec.field "them" .them Codec.string
                |> Codec.buildObject
            )
        |> Codec.variant1 "OtherMessage" OtherMessage Codec.string
        |> Codec.buildCustom


effectCodec : Codec Effect
effectCodec =
    Codec.custom
        (\knockoutEncoder knockdownEncoder crippledLeftLegEncoder crippledRightLegEncoder crippledLeftArmEncoder crippledRightArmEncoder blindedEncoder deathEncoder bypassArmorEncoder loseNextTurnEncoder value ->
            case value of
                Knockout ->
                    knockoutEncoder

                Knockdown ->
                    knockdownEncoder

                CrippledLeftLeg ->
                    crippledLeftLegEncoder

                CrippledRightLeg ->
                    crippledRightLegEncoder

                CrippledLeftArm ->
                    crippledLeftArmEncoder

                CrippledRightArm ->
                    crippledRightArmEncoder

                Blinded ->
                    blindedEncoder

                Death ->
                    deathEncoder

                BypassArmor ->
                    bypassArmorEncoder

                LoseNextTurn ->
                    loseNextTurnEncoder
        )
        |> Codec.variant0 "Knockout" Knockout
        |> Codec.variant0 "Knockdown" Knockdown
        |> Codec.variant0 "CrippledLeftLeg" CrippledLeftLeg
        |> Codec.variant0 "CrippledRightLeg" CrippledRightLeg
        |> Codec.variant0 "CrippledLeftArm" CrippledLeftArm
        |> Codec.variant0 "CrippledRightArm" CrippledRightArm
        |> Codec.variant0 "Blinded" Blinded
        |> Codec.variant0 "Death" Death
        |> Codec.variant0 "BypassArmor" BypassArmor
        |> Codec.variant0 "LoseNextTurn" LoseNextTurn
        |> Codec.buildCustom
