module Data.Fight exposing
    ( Action(..)
    , CommandRejectionReason(..)
    , Info
    , Opponent
    , Result(..)
    , Who(..)
    , attackDamage
    , attackStyle
    , encodeInfo
    , infoDecoder
    , isAttack
    , isCriticalAttack
    , isMiss
    , isNPC
    , isOpponentLivingCreature
    , isPlayer
    , opponentName
    , opponentXp
    , theOther
    )

import Data.Enemy.Type as EnemyType
import Data.Fight.AttackStyle as AttackStyle exposing (AttackStyle)
import Data.Fight.Critical as Critical
import Data.Fight.OpponentType as OpponentType exposing (OpponentType(..))
import Data.FightStrategy exposing (FightStrategy)
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Perk exposing (Perk)
import Data.Skill exposing (Skill)
import Data.Special exposing (Special)
import Data.Trait exposing (Trait)
import Dict exposing (Dict)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Json.Encode.Extra as JE
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


type alias Info =
    { attacker : OpponentType
    , target : OpponentType
    , log : List ( Who, Action )
    , result : Result
    }


type alias Opponent =
    { type_ : OpponentType
    , hp : Int
    , maxHp : Int
    , maxAp : Int
    , sequence : Int
    , traits : SeqSet Trait
    , perks : SeqDict Perk Int
    , caps : Int
    , items : Dict Item.Id Item
    , drops : List Item
    , level : Int
    , equippedArmor : Maybe ItemKind.Kind
    , equippedWeapon : Maybe ItemKind.Kind
    , preferredAmmo : Maybe ItemKind.Kind
    , naturalArmorClass : Int
    , addedSkillPercentages : SeqDict Skill Int
    , unarmedDamageBonus : Int
    , special : Special
    , fightStrategy : FightStrategy
    }


type Result
    = AttackerWon { xpGained : Int, capsGained : Int, itemsGained : List Item }
    | TargetWon { xpGained : Int, capsGained : Int, itemsGained : List Item }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead
    | NobodyDeadGivenUp


type Who
    = Attacker
    | Target


type Action
    = -- TODO later Reload, WalkAway, uncousciousness and other debuffs...
      Start { distanceHexes : Int }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , attackStyle : AttackStyle
        , remainingHp : Int
        , critical : Maybe ( List Critical.Effect, Critical.Message )
        , apCost : Int
        }
    | Miss
        { attackStyle : AttackStyle
        , apCost : Int

        -- TODO isCritical
        }
    | Heal
        { itemKind : ItemKind.Kind
        , healedHp : Int
        , newHp : Int
        }
    | SkipTurn
    | FailToDoAnything CommandRejectionReason


type CommandRejectionReason
    = Heal_ItemNotPresent
    | Heal_ItemDoesNotHeal
    | Heal_AlreadyFullyHealed
    | HealWithAnything_NoHealingItem
    | HealWithAnything_AlreadyFullyHealed
    | MoveForward_AlreadyNextToEachOther
    | Attack_NotCloseEnough
    | Attack_NotEnoughAP


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
        |> JD.andMap (JD.field "attacker" OpponentType.decoder)
        |> JD.andMap (JD.field "target" OpponentType.decoder)
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
        [ ( "attacker", OpponentType.encode info.attacker )
        , ( "target", OpponentType.encode info.target )
        , ( "log", JE.list encodeLogItem info.log )
        , ( "result", encodeResult info.result )
        ]


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

        NobodyDeadGivenUp ->
            JE.object [ ( "type", JE.string "NobodyDeadGivenUp" ) ]


resultDecoder : Decoder Result
resultDecoder =
    JD.oneOf
        [ resultDecoderV1
        ]


resultDecoderV1 : Decoder Result
resultDecoderV1 =
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

                    "NobodyDeadGivenUp" ->
                        JD.succeed NobodyDeadGivenUp

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
                , ( "attackStyle", AttackStyle.encode r.attackStyle )
                , ( "remainingHp", JE.int r.remainingHp )
                , ( "critical"
                  , JE.maybe
                        (\( effects, message ) ->
                            JE.object
                                [ ( "effects", JE.list Critical.encodeEffect effects )
                                , ( "message", Critical.encodeMessage message )
                                ]
                        )
                        r.critical
                  )
                , ( "apCost", JE.int r.apCost )
                ]

        Miss r ->
            JE.object
                [ ( "type", JE.string "Miss" )
                , ( "attackStyle", AttackStyle.encode r.attackStyle )
                , ( "apCost", JE.int r.apCost )
                ]

        Heal r ->
            JE.object
                [ ( "type", JE.string "Heal" )
                , ( "itemKind", ItemKind.encode r.itemKind )
                , ( "healedHp", JE.int r.healedHp )
                , ( "newHp", JE.int r.newHp )
                ]

        SkipTurn ->
            JE.object
                [ ( "type", JE.string "SkipTurn" )
                ]

        FailToDoAnything reason ->
            JE.object
                [ ( "type", JE.string "FailToDoAnything" )
                , ( "reason"
                  , JE.string <|
                        case reason of
                            Heal_ItemNotPresent ->
                                "Heal_ItemNotPresent"

                            Heal_ItemDoesNotHeal ->
                                "Heal_ItemDoesNotHeal"

                            Heal_AlreadyFullyHealed ->
                                "Heal_AlreadyFullyHealed"

                            HealWithAnything_NoHealingItem ->
                                "HealWithAnything_NoHealingItem"

                            HealWithAnything_AlreadyFullyHealed ->
                                "HealWithAnything_AlreadyFullyHealed"

                            MoveForward_AlreadyNextToEachOther ->
                                "MoveForward_AlreadyNextToEachOther"

                            Attack_NotCloseEnough ->
                                "Attack_NotCloseEnough"

                            Attack_NotEnoughAP ->
                                "Attack_NotEnoughAP"
                  )
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
                        JD.map2
                            (\attackStyle_ apCost ->
                                Miss
                                    { attackStyle = attackStyle_
                                    , apCost = apCost
                                    }
                            )
                            (JD.field "attackStyle" AttackStyle.decoder)
                            (JD.field "apCost" JD.int)

                    "Heal" ->
                        JD.map3
                            (\itemKind healedHp newHp ->
                                Heal
                                    { itemKind = itemKind
                                    , healedHp = healedHp
                                    , newHp = newHp
                                    }
                            )
                            (JD.field "itemKind" ItemKind.decoder)
                            (JD.field "healedHp" JD.int)
                            (JD.field "newHp" JD.int)

                    "SkipTurn" ->
                        JD.succeed SkipTurn

                    "FailToDoAnything" ->
                        JD.map FailToDoAnything (JD.field "reason" commandRejectionReasonDecoder)

                    _ ->
                        JD.fail <| "Unknown Fight.Action: '" ++ type_ ++ "'"
            )


commandRejectionReasonDecoder : Decoder CommandRejectionReason
commandRejectionReasonDecoder =
    JD.string
        |> JD.andThen
            (\reason ->
                case reason of
                    "Heal_AlreadyFullyHealed" ->
                        JD.succeed Heal_AlreadyFullyHealed

                    "Heal_ItemDoesNotHeal" ->
                        JD.succeed Heal_ItemDoesNotHeal

                    "Heal_ItemNotPresent" ->
                        JD.succeed Heal_ItemNotPresent

                    "HealWithAnything_NoHealingItem" ->
                        JD.succeed HealWithAnything_NoHealingItem

                    "HealWithAnything_AlreadyFullyHealed" ->
                        JD.succeed HealWithAnything_AlreadyFullyHealed

                    "Attack_NotCloseEnough" ->
                        JD.succeed Attack_NotCloseEnough

                    "Attack_NotEnoughAP" ->
                        JD.succeed Attack_NotEnoughAP

                    "MoveForward_AlreadyNextToEachOther" ->
                        JD.succeed MoveForward_AlreadyNextToEachOther

                    _ ->
                        JD.fail <| "Unknown CommandRejectionReason: '" ++ reason ++ "'"
            )


attackActionDecoder : Decoder Action
attackActionDecoder =
    JD.map5
        (\damage attackStyle_ remainingHp critical apCost ->
            Attack
                { damage = damage
                , attackStyle = attackStyle_
                , remainingHp = remainingHp
                , critical = critical
                , apCost = apCost
                }
        )
        (JD.field "damage" JD.int)
        (JD.field "attackStyle" AttackStyle.decoder)
        (JD.field "remainingHp" JD.int)
        (JD.field "critical"
            (JD.maybe
                (JD.map2 Tuple.pair
                    (JD.field "effects" (JD.list Critical.effectDecoder))
                    (JD.field "message" Critical.messageDecoder)
                )
            )
        )
        (JD.field "apCost" JD.int)


opponentName : OpponentType -> String
opponentName opponentType =
    case opponentType of
        Npc enemyType ->
            EnemyType.name enemyType

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


isNPC : OpponentType -> Bool
isNPC opponentType =
    case opponentType of
        Npc _ ->
            True

        Player _ ->
            False


attackDamage : Action -> Int
attackDamage action =
    case action of
        Attack { damage } ->
            damage

        Miss _ ->
            0

        Start _ ->
            0

        ComeCloser _ ->
            0

        Heal _ ->
            0

        SkipTurn ->
            0

        FailToDoAnything _ ->
            0


attackStyle : Action -> Maybe AttackStyle
attackStyle action =
    case action of
        Attack r ->
            Just r.attackStyle

        Miss r ->
            Just r.attackStyle

        Start _ ->
            Nothing

        ComeCloser _ ->
            Nothing

        Heal _ ->
            Nothing

        SkipTurn ->
            Nothing

        FailToDoAnything _ ->
            Nothing


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
        Attack { critical } ->
            critical /= Nothing

        _ ->
            False


isMiss : Action -> Bool
isMiss action =
    case action of
        Miss _ ->
            True

        _ ->
            False


isOpponentLivingCreature : Opponent -> Bool
isOpponentLivingCreature opponent =
    case opponent.type_ of
        Npc enemy ->
            EnemyType.isLivingCreature enemy

        Player _ ->
            True
