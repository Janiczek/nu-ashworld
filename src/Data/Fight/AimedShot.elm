module Data.Fight.AimedShot exposing
    ( AimedShot(..)
    , all
    , codec
    , toString
    )

import Codec exposing (Codec)


type AimedShot
    = Head
    | Torso
    | Eyes
    | Groin
    | LeftArm
    | RightArm
    | LeftLeg
    | RightLeg


all : List AimedShot
all =
    [ Head
    , Torso
    , Eyes
    , Groin
    , LeftArm
    , RightArm
    , LeftLeg
    , RightLeg
    ]


{-| TODO What purpose is this string for? Name the function better
-}
toString : AimedShot -> String
toString aimedShot =
    case aimedShot of
        Head ->
            "head"

        Torso ->
            "torso"

        Eyes ->
            "eyes"

        Groin ->
            "groin"

        LeftArm ->
            "left arm"

        RightArm ->
            "right arm"

        LeftLeg ->
            "left leg"

        RightLeg ->
            "right leg"


codec : Codec AimedShot
codec =
    Codec.custom
        (\headEncoder torsoEncoder eyesEncoder groinEncoder leftArmEncoder rightArmEncoder leftLegEncoder rightLegEncoder value ->
            case value of
                Head ->
                    headEncoder

                Torso ->
                    torsoEncoder

                Eyes ->
                    eyesEncoder

                Groin ->
                    groinEncoder

                LeftArm ->
                    leftArmEncoder

                RightArm ->
                    rightArmEncoder

                LeftLeg ->
                    leftLegEncoder

                RightLeg ->
                    rightLegEncoder
        )
        |> Codec.variant0 "Head" Head
        |> Codec.variant0 "Torso" Torso
        |> Codec.variant0 "Eyes" Eyes
        |> Codec.variant0 "Groin" Groin
        |> Codec.variant0 "LeftArm" LeftArm
        |> Codec.variant0 "RightArm" RightArm
        |> Codec.variant0 "LeftLeg" LeftLeg
        |> Codec.variant0 "RightLeg" RightLeg
        |> Codec.buildCustom
