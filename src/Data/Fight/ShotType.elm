module Data.Fight.ShotType exposing
    ( AimedShot(..)
    , ShotType(..)
    , all
    , allAimed
    , apCostPenalty
    , chanceToHitPenalty
    , decoder
    , encode
    , isAimed
    , toAimed
    )

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE


type ShotType
    = NormalShot
    | AimedShot AimedShot


type AimedShot
    = Head
    | Torso
    | Eyes
    | Groin
    | LeftArm
    | RightArm
    | LeftLeg
    | RightLeg


isAimed : ShotType -> Bool
isAimed shot =
    case shot of
        NormalShot ->
            False

        AimedShot _ ->
            True


allAimed : List AimedShot
allAimed =
    [ Head
    , Torso
    , Eyes
    , Groin
    , LeftArm
    , RightArm
    , LeftLeg
    , RightLeg
    ]


all : List ShotType
all =
    NormalShot
        :: List.map AimedShot allAimed


apCostPenalty : { isAimedShot : Bool } -> Int
apCostPenalty { isAimedShot } =
    if isAimedShot then
        1

    else
        0


chanceToHitPenalty : ShotType -> Int
chanceToHitPenalty shot =
    case shot of
        NormalShot ->
            0

        AimedShot aimedShot ->
            aimedShotPenalty aimedShot


aimedShotPenalty : AimedShot -> Int
aimedShotPenalty shot =
    case shot of
        Head ->
            40

        Torso ->
            0

        Eyes ->
            60

        Groin ->
            30

        LeftArm ->
            30

        RightArm ->
            30

        LeftLeg ->
            20

        RightLeg ->
            20


encode : ShotType -> JE.Value
encode shotType =
    case shotType of
        NormalShot ->
            JE.object [ ( "type", JE.string "NormalShot" ) ]

        AimedShot aimed ->
            JE.object
                [ ( "type", JE.string "AimedShot" )
                , ( "aimedShot", encodeAimedShot aimed )
                ]


decoder : Decoder ShotType
decoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "NormalShot" ->
                        JD.succeed NormalShot

                    "AimedShot" ->
                        JD.map AimedShot (JD.field "aimedShot" aimedShotDecoder)

                    _ ->
                        JD.fail <| "Unknown ShotType: '" ++ type_ ++ "'"
            )


encodeAimedShot : AimedShot -> JE.Value
encodeAimedShot aimed =
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


aimedShotDecoder : Decoder AimedShot
aimedShotDecoder =
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


toAimed : ShotType -> AimedShot
toAimed shotType =
    case shotType of
        NormalShot ->
            Torso

        AimedShot aimedShot ->
            aimedShot
