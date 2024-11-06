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
    Codec.enum Codec.string
        [ ( "Head", Head )
        , ( "Torso", Torso )
        , ( "Eyes", Eyes )
        , ( "Groin", Groin )
        , ( "LeftArm", LeftArm )
        , ( "RightArm", RightArm )
        , ( "LeftLeg", LeftLeg )
        , ( "RightLeg", RightLeg )
        ]
