module Data.Fight.AimedShot exposing
    ( AimedShot(..)
    , all
    , decoder
    , encode
    , toString
    )

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


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


encode : AimedShot -> JE.Value
encode aimed =
    case aimed of
        Head ->
            JE.string "Head"

        Torso ->
            JE.string "Torso"

        Eyes ->
            JE.string "Eyes"

        Groin ->
            JE.string "Groin"

        LeftArm ->
            JE.string "LeftArm"

        RightArm ->
            JE.string "RightArm"

        LeftLeg ->
            JE.string "LeftLeg"

        RightLeg ->
            JE.string "RightLeg"


decoder : Decoder AimedShot
decoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Head" ->
                        JD.succeed Head

                    "Torso" ->
                        JD.succeed Torso

                    "Eyes" ->
                        JD.succeed Eyes

                    "Groin" ->
                        JD.succeed Groin

                    "LeftArm" ->
                        JD.succeed LeftArm

                    "RightArm" ->
                        JD.succeed RightArm

                    "LeftLeg" ->
                        JD.succeed LeftLeg

                    "RightLeg" ->
                        JD.succeed RightLeg

                    _ ->
                        JD.fail <| "Unknown AimedShot: '" ++ type_ ++ "'"
            )


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
