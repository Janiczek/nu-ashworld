module Data.Fight.AttackStyle exposing
    ( AttackStyle(..)
    , all
    , toShotType
    , toString
    )

import Data.Fight.ShotType as ShotType exposing (AimedShot(..), ShotType(..))


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed AimedShot
    | MeleeUnaimed
    | MeleeAimed AimedShot
    | ThrowUnaimed
    | ThrowAimed AimedShot
    | ShootSingleUnaimed
    | ShootSingleAimed AimedShot
    | ShootBurst


all : List AttackStyle
all =
    UnarmedUnaimed
        :: MeleeUnaimed
        :: ThrowUnaimed
        :: ShootSingleUnaimed
        :: ShootBurst
        :: (ShotType.allAimed
                |> List.concatMap
                    (\aimed ->
                        [ UnarmedAimed aimed
                        , MeleeAimed aimed
                        , ThrowAimed aimed
                        , ShootSingleAimed aimed
                        ]
                    )
           )


toString : AttackStyle -> String
toString style =
    case style of
        UnarmedUnaimed ->
            "unarmed"

        UnarmedAimed aimed ->
            "unarmed, " ++ aimedShotToString aimed

        MeleeUnaimed ->
            "melee"

        MeleeAimed aimed ->
            "melee, " ++ aimedShotToString aimed

        ThrowUnaimed ->
            "throw"

        ThrowAimed aimed ->
            "throw, " ++ aimedShotToString aimed

        ShootSingleUnaimed ->
            "shoot"

        ShootSingleAimed aimed ->
            "shoot, " ++ aimedShotToString aimed

        ShootBurst ->
            "burst"


aimedShotToString : AimedShot -> String
aimedShotToString aimedShot =
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


toShotType : AttackStyle -> ShotType
toShotType attackStyle =
    case attackStyle of
        UnarmedUnaimed ->
            NormalShot

        UnarmedAimed aimed ->
            AimedShot aimed

        MeleeUnaimed ->
            NormalShot

        MeleeAimed aimed ->
            AimedShot aimed

        ThrowUnaimed ->
            NormalShot

        ThrowAimed aimed ->
            AimedShot aimed

        ShootSingleUnaimed ->
            NormalShot

        ShootSingleAimed aimed ->
            AimedShot aimed

        ShootBurst ->
            BurstShot
