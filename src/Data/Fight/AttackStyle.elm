module Data.Fight.AttackStyle exposing
    ( AttackStyle(..)
    , all
    , decoder
    , encode
    , isAimed
    , isUnaimed
    , isUnarmed
    , toAimed
    , toString
    )

import Data.Fight.AimedShot as AimedShot exposing (AimedShot)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
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


decoder : Decoder AttackStyle
decoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "UnarmedUnaimed" ->
                        JD.succeed UnarmedUnaimed

                    "UnarmedAimed" ->
                        JD.map UnarmedAimed (JD.field "aimedShot" AimedShot.decoder)

                    "MeleeUnaimed" ->
                        JD.succeed MeleeUnaimed

                    "MeleeAimed" ->
                        JD.map MeleeAimed (JD.field "aimedShot" AimedShot.decoder)

                    "Throw" ->
                        JD.succeed Throw

                    "ShootSingleUnaimed" ->
                        JD.succeed ShootSingleUnaimed

                    "ShootSingleAimed" ->
                        JD.map ShootSingleAimed (JD.field "aimedShot" AimedShot.decoder)

                    "ShootBurst" ->
                        JD.succeed ShootBurst

                    _ ->
                        JD.fail <| "Unknown AttackStyle type: " ++ type_
            )


encode : AttackStyle -> JE.Value
encode attackStyle =
    case attackStyle of
        UnarmedUnaimed ->
            JE.object [ ( "type", JE.string "UnarmedUnaimed" ) ]

        UnarmedAimed aimedShot ->
            JE.object
                [ ( "type", JE.string "UnarmedAimed" )
                , ( "aimedShot", AimedShot.encode aimedShot )
                ]

        MeleeUnaimed ->
            JE.object [ ( "type", JE.string "MeleeUnaimed" ) ]

        MeleeAimed aimedShot ->
            JE.object
                [ ( "type", JE.string "MeleeAimed" )
                , ( "aimedShot", AimedShot.encode aimedShot )
                ]

        Throw ->
            JE.object [ ( "type", JE.string "Throw" ) ]

        ShootSingleUnaimed ->
            JE.object [ ( "type", JE.string "ShootSingleUnaimed" ) ]

        ShootSingleAimed aimedShot ->
            JE.object
                [ ( "type", JE.string "ShootSingleAimed" )
                , ( "aimedShot", AimedShot.encode aimedShot )
                ]

        ShootBurst ->
            JE.object [ ( "type", JE.string "ShootBurst" ) ]


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
