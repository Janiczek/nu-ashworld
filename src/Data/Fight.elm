module Data.Fight exposing
    ( Action(..)
    , Info
    , Opponent
    , OpponentType(..)
    , Result(..)
    , Who(..)
    , attackDamage
    , encodeInfo
    , infoDecoder
    , isAttack
    , isCriticalAttack
    , isMiss
    , isPlayer
    , opponentName
    , opponentXp
    , theOther
    )

import AssocList as Dict_
import AssocSet as Set_
import Data.Enemy as Enemy
import Data.Fight.ShotType as ShotType exposing (ShotType)
import Data.Item as Item exposing (Item)
import Data.Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait exposing (Trait)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Logic exposing (AttackStats)


type alias Info =
    { attacker : OpponentType
    , target : OpponentType
    , log : List ( Who, Action )
    , result : Result
    }


type OpponentType
    = Npc Enemy.Type
    | Player PlayerOpponent


type alias PlayerOpponent =
    { name : PlayerName
    , xp : Int
    }


type alias Opponent =
    { type_ : OpponentType
    , hp : Int
    , maxHp : Int
    , maxAp : Int
    , sequence : Int
    , traits : Set_.Set Trait
    , perks : Dict_.Dict Perk Int
    , caps : Int
    , drops : List Item
    , equippedArmor : Maybe Item.Kind
    , naturalArmorClass : Int
    , attackStats : AttackStats
    , addedSkillPercentages : Dict_.Dict Skill Int
    , special : Special
    }


type Result
    = AttackerWon { xpGained : Int, capsGained : Int, itemsGained : List Item }
    | TargetWon { xpGained : Int, capsGained : Int, itemsGained : List Item }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


type Who
    = Attacker
    | Target


type Action
    = -- TODO later Reload, Heal, WalkAway, uncousciousness and other debuffs...
      Start { distanceHexes : Int }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , shotType : ShotType
        , remainingHp : Int
        , isCritical : Bool -- TODO the string
        }
    | Miss { shotType : ShotType }


theOther : Who -> Who
theOther who =
    case who of
        Attacker ->
            Target

        Target ->
            Attacker


infoDecoder : Decoder Info
infoDecoder =
    let
        logItemDecoder : Decoder ( Who, Action )
        logItemDecoder =
            JD.map2 Tuple.pair
                (JD.field "who" whoDecoder)
                (JD.field "action" actionDecoder)
    in
    JD.succeed Info
        |> JD.andMap (JD.field "attacker" opponentTypeDecoder)
        |> JD.andMap (JD.field "target" opponentTypeDecoder)
        |> JD.andMap (JD.field "log" (JD.list logItemDecoder))
        |> JD.andMap (JD.field "result" resultDecoder)


encodeInfo : Info -> JE.Value
encodeInfo info =
    let
        encodeLogItem : ( Who, Action ) -> JE.Value
        encodeLogItem ( who, action ) =
            JE.object
                [ ( "who", encodeWho who )
                , ( "action", encodeAction action )
                ]
    in
    JE.object
        [ ( "attacker", encodeOpponentType info.attacker )
        , ( "target", encodeOpponentType info.target )
        , ( "log", JE.list encodeLogItem info.log )
        , ( "result", encodeResult info.result )
        ]


encodeOpponentType : OpponentType -> JE.Value
encodeOpponentType opponentType =
    case opponentType of
        Npc enemyType ->
            JE.object
                [ ( "type", JE.string "npc" )
                , ( "enemyType", Enemy.encodeType enemyType )
                ]

        Player { name, xp } ->
            JE.object
                [ ( "type", JE.string "player" )
                , ( "name", JE.string name )
                , ( "xp", JE.int xp )
                ]


opponentTypeDecoder : Decoder OpponentType
opponentTypeDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "npc" ->
                        JD.map Npc Enemy.typeDecoder

                    "player" ->
                        JD.map Player
                            (JD.succeed PlayerOpponent
                                |> JD.andMap (JD.field "name" JD.string)
                                |> JD.andMap
                                    (JD.maybe (JD.field "xp" JD.int)
                                        |> JD.map (Maybe.withDefault 1)
                                    )
                            )

                    _ ->
                        JD.fail <| "Unknown Opponent type: '" ++ type_ ++ "'"
            )


encodeResult : Result -> JE.Value
encodeResult result =
    case result of
        AttackerWon r ->
            JE.object
                [ ( "type", JE.string "AttackerWon" )
                , ( "xpGained", JE.int r.xpGained )
                , ( "capsGained", JE.int r.capsGained )
                , ( "itemsGained", JE.list Item.encode r.itemsGained )
                ]

        TargetWon r ->
            JE.object
                [ ( "type", JE.string "TargetWon" )
                , ( "xpGained", JE.int r.xpGained )
                , ( "capsGained", JE.int r.capsGained )
                , ( "itemsGained", JE.list Item.encode r.itemsGained )
                ]

        TargetAlreadyDead ->
            JE.object [ ( "type", JE.string "TargetAlreadyDead" ) ]

        BothDead ->
            JE.object [ ( "type", JE.string "BothDead" ) ]

        NobodyDead ->
            JE.object [ ( "type", JE.string "NobodyDead" ) ]


resultDecoder : Decoder Result
resultDecoder =
    JD.oneOf
        [ resultDecoderV2
        , resultDecoderV1
        ]


{-| Original
-}
resultDecoderV1 : Decoder Result
resultDecoderV1 =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "AttackerWon" ->
                        JD.map2
                            (\xp caps ->
                                AttackerWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    , itemsGained = []
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)

                    "TargetWon" ->
                        JD.map2
                            (\xp caps ->
                                TargetWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    , itemsGained = []
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)

                    "TargetAlreadyDead" ->
                        JD.succeed TargetAlreadyDead

                    "BothDead" ->
                        JD.succeed BothDead

                    "NobodyDead" ->
                        JD.succeed NobodyDead

                    _ ->
                        JD.fail <| "Unknown Fight.Result: '" ++ type_ ++ "'"
            )


{-| Adding the `itemsGained` field
-}
resultDecoderV2 : Decoder Result
resultDecoderV2 =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "AttackerWon" ->
                        JD.map3
                            (\xp caps items ->
                                AttackerWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    , itemsGained = items
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)
                            (JD.field "itemsGained" (JD.list Item.decoder))

                    "TargetWon" ->
                        JD.map3
                            (\xp caps items ->
                                TargetWon
                                    { xpGained = xp
                                    , capsGained = caps
                                    , itemsGained = items
                                    }
                            )
                            (JD.field "xpGained" JD.int)
                            (JD.field "capsGained" JD.int)
                            (JD.field "itemsGained" (JD.list Item.decoder))

                    "TargetAlreadyDead" ->
                        JD.succeed TargetAlreadyDead

                    "BothDead" ->
                        JD.succeed BothDead

                    "NobodyDead" ->
                        JD.succeed NobodyDead

                    _ ->
                        JD.fail <| "Unknown Fight.Result: '" ++ type_ ++ "'"
            )


encodeWho : Who -> JE.Value
encodeWho who =
    case who of
        Attacker ->
            JE.string "attacker"

        Target ->
            JE.string "target"


whoDecoder : Decoder Who
whoDecoder =
    JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "attacker" ->
                        JD.succeed Attacker

                    "target" ->
                        JD.succeed Target

                    _ ->
                        JD.fail <| "Unknown Who: '" ++ type_ ++ "'"
            )


encodeAction : Action -> JE.Value
encodeAction action =
    case action of
        Start r ->
            JE.object
                [ ( "type", JE.string "Start" )
                , ( "distanceHexes", JE.int r.distanceHexes )
                ]

        ComeCloser r ->
            JE.object
                [ ( "type", JE.string "ComeCloser" )
                , ( "hexes", JE.int r.hexes )
                , ( "remainingDistanceHexes", JE.int r.remainingDistanceHexes )
                ]

        Attack r ->
            JE.object
                [ ( "type", JE.string "Attack" )
                , ( "damage", JE.int r.damage )
                , ( "shotType", ShotType.encode r.shotType )
                , ( "remainingHp", JE.int r.remainingHp )
                , ( "isCritical", JE.bool r.isCritical )
                ]

        Miss r ->
            JE.object
                [ ( "type", JE.string "Miss" )
                , ( "shotType", ShotType.encode r.shotType )
                ]


actionDecoder : Decoder Action
actionDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "Start" ->
                        JD.field "distanceHexes" JD.int
                            |> JD.map (\distance -> Start { distanceHexes = distance })

                    "ComeCloser" ->
                        JD.map2
                            (\hexes remaining ->
                                ComeCloser
                                    { hexes = hexes
                                    , remainingDistanceHexes = remaining
                                    }
                            )
                            (JD.field "hexes" JD.int)
                            (JD.field "remainingDistanceHexes" JD.int)

                    "Attack" ->
                        attackActionDecoder

                    "Miss" ->
                        JD.field "shotType" ShotType.decoder
                            |> JD.map (\shotType -> Miss { shotType = shotType })

                    _ ->
                        JD.fail <| "Unknown Fight.Action: '" ++ type_ ++ "'"
            )


attackActionDecoder : Decoder Action
attackActionDecoder =
    JD.oneOf
        [ attackActionDecoderV2
        , attackActionDecoderV1
        ]


attackActionDecoderV1 : Decoder Action
attackActionDecoderV1 =
    JD.map3
        (\damage shotType remainingHp ->
            Attack
                { damage = damage
                , shotType = shotType
                , remainingHp = remainingHp
                , isCritical = False
                }
        )
        (JD.field "damage" JD.int)
        (JD.field "shotType" ShotType.decoder)
        (JD.field "remainingHp" JD.int)


attackActionDecoderV2 : Decoder Action
attackActionDecoderV2 =
    JD.map4
        (\damage shotType remainingHp isCritical ->
            Attack
                { damage = damage
                , shotType = shotType
                , remainingHp = remainingHp
                , isCritical = isCritical
                }
        )
        (JD.field "damage" JD.int)
        (JD.field "shotType" ShotType.decoder)
        (JD.field "remainingHp" JD.int)
        (JD.field "isCritical" JD.bool)


opponentName : OpponentType -> String
opponentName opponentType =
    case opponentType of
        Npc enemyType ->
            Enemy.name enemyType

        Player { name } ->
            name


opponentXp : OpponentType -> Int
opponentXp opponentType =
    case opponentType of
        Npc _ ->
            -- We don't care.
            1

        Player { xp } ->
            xp


isPlayer : OpponentType -> Bool
isPlayer opponentType =
    case opponentType of
        Npc _ ->
            False

        Player _ ->
            True


attackDamage : Action -> Int
attackDamage action =
    case action of
        Attack { damage } ->
            damage

        _ ->
            0


isAttack : Action -> Bool
isAttack action =
    case action of
        Attack _ ->
            True

        _ ->
            False


isCriticalAttack : Action -> Bool
isCriticalAttack action =
    case action of
        Attack { isCritical } ->
            isCritical

        _ ->
            False


isMiss : Action -> Bool
isMiss action =
    case action of
        Miss _ ->
            True

        _ ->
            False
