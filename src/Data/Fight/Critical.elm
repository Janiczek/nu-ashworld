module Data.Fight.Critical exposing
    ( Critical
    , Effect(..)
    , EffectCategory(..)
    , Message(..)
    , Spec
    , effectDecoder
    , encodeEffect
    , encodeMessage
    , messageDecoder
    , toCategory
    )

import Data.Special as Special
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


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


encodeEffect : Effect -> JE.Value
encodeEffect effect =
    case effect of
        Knockout ->
            JE.string "Knockout"

        Knockdown ->
            JE.string "Knockdown"

        CrippledLeftLeg ->
            JE.string "CrippledLeftLeg"

        CrippledRightLeg ->
            JE.string "CrippledRightLeg"

        CrippledLeftArm ->
            JE.string "CrippledLeftArm"

        CrippledRightArm ->
            JE.string "CrippledRightArm"

        Blinded ->
            JE.string "Blinded"

        Death ->
            JE.string "Death"

        BypassArmor ->
            JE.string "BypassArmor"

        LoseNextTurn ->
            JE.string "LoseNextTurn"


effectDecoder : Decoder Effect
effectDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "Knockout" ->
                        JD.succeed Knockout

                    "Knockdown" ->
                        JD.succeed Knockdown

                    "CrippledLeftLeg" ->
                        JD.succeed CrippledLeftLeg

                    "CrippledRightLeg" ->
                        JD.succeed CrippledRightLeg

                    "CrippledLeftArm" ->
                        JD.succeed CrippledLeftArm

                    "CrippledRightArm" ->
                        JD.succeed CrippledRightArm

                    "Blinded" ->
                        JD.succeed Blinded

                    "Death" ->
                        JD.succeed Death

                    "BypassArmor" ->
                        JD.succeed BypassArmor

                    "LoseNextTurn" ->
                        JD.succeed LoseNextTurn

                    _ ->
                        JD.fail <| "Unknown effect: " ++ str
            )


encodeMessage : Message -> JE.Value
encodeMessage message =
    case message of
        PlayerMessage arg0 ->
            JE.object
                [ ( "tag", JE.string "PlayerMessage" )
                , ( "message"
                  , JE.object
                        [ ( "you", JE.string arg0.you )
                        , ( "them", JE.string arg0.them )
                        ]
                  )
                ]

        OtherMessage arg0 ->
            JE.object
                [ ( "tag", JE.string "OtherMessage" )
                , ( "message", JE.string arg0 )
                ]


messageDecoder : Decoder Message
messageDecoder =
    JD.field "tag" JD.string
        |> JD.andThen
            (\ctor ->
                case ctor of
                    "PlayerMessage" ->
                        JD.map
                            PlayerMessage
                            (JD.field
                                "message"
                                (JD.map2
                                    (\you them -> { you = you, them = them })
                                    (JD.field "you" JD.string)
                                    (JD.field "them" JD.string)
                                )
                            )

                    "OtherMessage" ->
                        JD.map OtherMessage (JD.field "message" JD.string)

                    _ ->
                        JD.fail <| "Unrecognized constructor: " ++ ctor
            )
