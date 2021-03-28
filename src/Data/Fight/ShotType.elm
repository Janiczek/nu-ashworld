module Data.Fight.ShotType exposing
    ( AimedShot(..)
    , ShotType(..)
    , all
    , allAimed
    , apCostPenalty
    , chanceToHitPenalty
    , isAimed
    , label
    )


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


all : List ShotType
all =
    NormalShot
        :: List.map AimedShot allAimed


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


label : AimedShot -> String
label shot =
    case shot of
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
