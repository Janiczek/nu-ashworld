module Data.Fight.AttackStyle exposing
    ( AttackStyle(..)
    , all
    , codec
    , isAimed
    , isUnaimed
    , isUnarmed
    , toAimed
    , toString
    )

import Codec exposing (Codec)
import Data.Fight.AimedShot as AimedShot exposing (AimedShot)
import List.ExtraExtra as List


type AttackStyle
    = UnarmedUnaimed
    | UnarmedAimed AimedShot
    | MeleeUnaimed
    | MeleeAimed AimedShot
    | Throw
    | ShootSingleUnaimed
    | ShootSingleAimed AimedShot
    | ShootBurst


all : List AttackStyle
all =
    UnarmedUnaimed
        :: MeleeUnaimed
        :: Throw
        :: ShootSingleUnaimed
        :: ShootBurst
        :: (AimedShot.all
                |> List.fastConcatMap
                    (\aimed ->
                        [ UnarmedAimed aimed
                        , MeleeAimed aimed
                        , ShootSingleAimed aimed
                        ]
                    )
           )


isUnaimed : AttackStyle -> Bool
isUnaimed style =
    case style of
        UnarmedUnaimed ->
            True

        UnarmedAimed _ ->
            False

        MeleeUnaimed ->
            True

        MeleeAimed _ ->
            False

        Throw ->
            True

        ShootSingleUnaimed ->
            True

        ShootSingleAimed _ ->
            False

        ShootBurst ->
            False


isAimed : AttackStyle -> Bool
isAimed style =
    case style of
        UnarmedUnaimed ->
            False

        UnarmedAimed _ ->
            True

        MeleeUnaimed ->
            False

        MeleeAimed _ ->
            True

        Throw ->
            False

        ShootSingleUnaimed ->
            False

        ShootSingleAimed _ ->
            True

        ShootBurst ->
            False


toAimed : AttackStyle -> Maybe AimedShot
toAimed style =
    case style of
        UnarmedUnaimed ->
            Nothing

        UnarmedAimed aim ->
            Just aim

        MeleeUnaimed ->
            Nothing

        MeleeAimed aim ->
            Just aim

        Throw ->
            Nothing

        ShootSingleUnaimed ->
            Nothing

        ShootSingleAimed aim ->
            Just aim

        ShootBurst ->
            Nothing


{-| TODO What purpose is this string for? Name the function better
-}
toString : AttackStyle -> String
toString style =
    case style of
        UnarmedUnaimed ->
            "unarmed"

        UnarmedAimed aimed ->
            "unarmed, " ++ AimedShot.toString aimed

        MeleeUnaimed ->
            "melee"

        MeleeAimed aimed ->
            "melee, " ++ AimedShot.toString aimed

        Throw ->
            "throw"

        ShootSingleUnaimed ->
            "shoot"

        ShootSingleAimed aimed ->
            "shoot, " ++ AimedShot.toString aimed

        ShootBurst ->
            "burst"


codec : Codec AttackStyle
codec =
    Codec.custom
        (\unarmedUnaimedEncoder unarmedAimedEncoder meleeUnaimedEncoder meleeAimedEncoder throwEncoder shootSingleUnaimedEncoder shootSingleAimedEncoder shootBurstEncoder value ->
            case value of
                UnarmedUnaimed ->
                    unarmedUnaimedEncoder

                UnarmedAimed arg0 ->
                    unarmedAimedEncoder arg0

                MeleeUnaimed ->
                    meleeUnaimedEncoder

                MeleeAimed arg0 ->
                    meleeAimedEncoder arg0

                Throw ->
                    throwEncoder

                ShootSingleUnaimed ->
                    shootSingleUnaimedEncoder

                ShootSingleAimed arg0 ->
                    shootSingleAimedEncoder arg0

                ShootBurst ->
                    shootBurstEncoder
        )
        |> Codec.variant0 "UnarmedUnaimed" UnarmedUnaimed
        |> Codec.variant1 "UnarmedAimed" UnarmedAimed AimedShot.codec
        |> Codec.variant0 "MeleeUnaimed" MeleeUnaimed
        |> Codec.variant1 "MeleeAimed" MeleeAimed AimedShot.codec
        |> Codec.variant0 "Throw" Throw
        |> Codec.variant0 "ShootSingleUnaimed" ShootSingleUnaimed
        |> Codec.variant1 "ShootSingleAimed" ShootSingleAimed AimedShot.codec
        |> Codec.variant0 "ShootBurst" ShootBurst
        |> Codec.buildCustom


isUnarmed : AttackStyle -> Bool
isUnarmed style =
    case style of
        UnarmedUnaimed ->
            True

        UnarmedAimed _ ->
            True

        MeleeUnaimed ->
            False

        MeleeAimed _ ->
            False

        Throw ->
            False

        ShootSingleUnaimed ->
            False

        ShootSingleAimed _ ->
            False

        ShootBurst ->
            False
