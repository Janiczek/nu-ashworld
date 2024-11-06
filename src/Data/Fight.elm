module Data.Fight exposing
    ( Action(..)
    , CommandRejectionReason(..)
    , Equipment
    , Info
    , Opponent
    , Result(..)
    , Who(..)
    , attackDamage
    , attackStyle
    , infoCodec
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

import Codec exposing (Codec)
import Data.Enemy as Enemy
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
import SeqDict exposing (SeqDict)
import SeqSet exposing (SeqSet)


type alias Equipment =
    -- Maybes because the player might not have the item equipped
    { weapon : Maybe ItemKind.Kind
    , armor : Maybe ItemKind.Kind
    }


type alias Info =
    { attacker : OpponentType
    , target : OpponentType
    , log : List ( Who, Action )
    , result : Result

    -- Maybe because the info might not be available due to player not having the Awareness perk
    , attackerEquipment : Maybe Equipment
    , targetEquipment : Maybe Equipment
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
    , drops : List ( Item, List Enemy.Requirement )
    , level : Int
    , equippedArmor : Maybe ItemKind.Kind
    , equippedWeapon : Maybe ItemKind.Kind
    , preferredAmmo : Maybe ItemKind.Kind
    , naturalArmorClass : Int
    , addedSkillPercentages : SeqDict Skill Int
    , unarmedDamageBonus : Int
    , special : Special
    , fightStrategy : FightStrategy

    -- Short-term health effects (don't persist to the SPlayer)
    -- blindness -> sets special.perception to 1. We just need to make sure this doesn't get persisted to the SPlayer later
    , knockedOutTurns : Int
    , isKnockedDown : Bool
    , crippledLeftLeg : Bool
    , crippledRightLeg : Bool
    , crippledLeftArm : Bool
    , crippledRightArm : Bool
    , losesNextTurn : Bool
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
    | KnockedOut
    | StandUp { apCost : Int }
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


infoCodec : Codec Info
infoCodec =
    Codec.object Info
        |> Codec.field "attacker" .attacker OpponentType.codec
        |> Codec.field "target" .target OpponentType.codec
        |> Codec.field "log" .log (Codec.list (Codec.tuple whoCodec actionCodec))
        |> Codec.field "result" .result resultCodec
        |> Codec.field "attackerEquipment" .attackerEquipment (Codec.nullable equipmentCodec)
        |> Codec.field "targetEquipment" .targetEquipment (Codec.nullable equipmentCodec)
        |> Codec.buildObject


equipmentCodec : Codec Equipment
equipmentCodec =
    Codec.object Equipment
        |> Codec.field "weapon" .weapon (Codec.nullable ItemKind.codec)
        |> Codec.field "armor" .armor (Codec.nullable ItemKind.codec)
        |> Codec.buildObject


whoCodec : Codec Who
whoCodec =
    Codec.enum Codec.string
        [ ( "Attacker", Attacker )
        , ( "Target", Target )
        ]


actionCodec : Codec Action
actionCodec =
    Codec.custom
        (\startEncoder comeCloserEncoder attackEncoder missEncoder healEncoder skipTurnEncoder knockedOutEncoder standUpEncoder failToDoAnythingEncoder value ->
            case value of
                Start arg0 ->
                    startEncoder arg0

                ComeCloser arg0 ->
                    comeCloserEncoder arg0

                Attack arg0 ->
                    attackEncoder arg0

                Miss arg0 ->
                    missEncoder arg0

                Heal arg0 ->
                    healEncoder arg0

                SkipTurn ->
                    skipTurnEncoder

                KnockedOut ->
                    knockedOutEncoder

                StandUp arg0 ->
                    standUpEncoder arg0

                FailToDoAnything arg0 ->
                    failToDoAnythingEncoder arg0
        )
        |> Codec.variant1
            "Start"
            Start
            (Codec.object (\distanceHexes -> { distanceHexes = distanceHexes })
                |> Codec.field "distanceHexes" .distanceHexes Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "ComeCloser"
            ComeCloser
            (Codec.object
                (\hexes remainingDistanceHexes -> { hexes = hexes, remainingDistanceHexes = remainingDistanceHexes })
                |> Codec.field "hexes" .hexes Codec.int
                |> Codec.field "remainingDistanceHexes" .remainingDistanceHexes Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "Attack"
            Attack
            (Codec.object
                (\damage attackStyle_ remainingHp critical apCost ->
                    { damage = damage
                    , attackStyle = attackStyle_
                    , remainingHp = remainingHp
                    , critical = critical
                    , apCost = apCost
                    }
                )
                |> Codec.field "damage" .damage Codec.int
                |> Codec.field "attackStyle" .attackStyle AttackStyle.codec
                |> Codec.field "remainingHp" .remainingHp Codec.int
                |> Codec.field "critical" .critical (Codec.nullable (Codec.tuple (Codec.list Critical.effectCodec) Critical.messageCodec))
                |> Codec.field "apCost" .apCost Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "Miss"
            Miss
            (Codec.object
                (\attackStyle_ apCost ->
                    { attackStyle = attackStyle_
                    , apCost = apCost
                    }
                )
                |> Codec.field "attackStyle" .attackStyle AttackStyle.codec
                |> Codec.field "apCost" .apCost Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1
            "Heal"
            Heal
            (Codec.object (\itemKind healedHp newHp -> { itemKind = itemKind, healedHp = healedHp, newHp = newHp })
                |> Codec.field "itemKind" .itemKind ItemKind.codec
                |> Codec.field "healedHp" .healedHp Codec.int
                |> Codec.field "newHp" .newHp Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant0 "SkipTurn" SkipTurn
        |> Codec.variant0 "KnockedOut" KnockedOut
        |> Codec.variant1
            "StandUp"
            StandUp
            (Codec.object (\apCost -> { apCost = apCost })
                |> Codec.field "apCost" .apCost Codec.int
                |> Codec.buildObject
            )
        |> Codec.variant1 "FailToDoAnything" FailToDoAnything commandRejectionReasonCodec
        |> Codec.buildCustom


commandRejectionReasonCodec : Codec CommandRejectionReason
commandRejectionReasonCodec =
    Codec.enum Codec.string
        [ ( "Heal_ItemNotPresent", Heal_ItemNotPresent )
        , ( "Heal_ItemDoesNotHeal", Heal_ItemDoesNotHeal )
        , ( "Heal_AlreadyFullyHealed", Heal_AlreadyFullyHealed )
        , ( "HealWithAnything_NoHealingItem", HealWithAnything_NoHealingItem )
        , ( "HealWithAnything_AlreadyFullyHealed", HealWithAnything_AlreadyFullyHealed )
        , ( "MoveForward_AlreadyNextToEachOther", MoveForward_AlreadyNextToEachOther )
        , ( "Attack_NotCloseEnough", Attack_NotCloseEnough )
        , ( "Attack_NotEnoughAP", Attack_NotEnoughAP )
        ]


resultCodec : Codec Result
resultCodec =
    Codec.custom
        (\attackerWonEncoder targetWonEncoder targetAlreadyDeadEncoder bothDeadEncoder nobodyDeadEncoder nobodyDeadGivenUpEncoder value ->
            case value of
                AttackerWon arg0 ->
                    attackerWonEncoder arg0

                TargetWon arg0 ->
                    targetWonEncoder arg0

                TargetAlreadyDead ->
                    targetAlreadyDeadEncoder

                BothDead ->
                    bothDeadEncoder

                NobodyDead ->
                    nobodyDeadEncoder

                NobodyDeadGivenUp ->
                    nobodyDeadGivenUpEncoder
        )
        |> Codec.variant1
            "AttackerWon"
            AttackerWon
            (Codec.object
                (\xpGained capsGained itemsGained ->
                    { xpGained = xpGained, capsGained = capsGained, itemsGained = itemsGained }
                )
                |> Codec.field "xpGained" .xpGained Codec.int
                |> Codec.field "capsGained" .capsGained Codec.int
                |> Codec.field "itemsGained" .itemsGained (Codec.list Item.codec)
                |> Codec.buildObject
            )
        |> Codec.variant1
            "TargetWon"
            TargetWon
            (Codec.object
                (\xpGained capsGained itemsGained ->
                    { xpGained = xpGained, capsGained = capsGained, itemsGained = itemsGained }
                )
                |> Codec.field "xpGained" .xpGained Codec.int
                |> Codec.field "capsGained" .capsGained Codec.int
                |> Codec.field "itemsGained" .itemsGained (Codec.list Item.codec)
                |> Codec.buildObject
            )
        |> Codec.variant0 "TargetAlreadyDead" TargetAlreadyDead
        |> Codec.variant0 "BothDead" BothDead
        |> Codec.variant0 "NobodyDead" NobodyDead
        |> Codec.variant0 "NobodyDeadGivenUp" NobodyDeadGivenUp
        |> Codec.buildCustom


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

        KnockedOut ->
            0

        Heal _ ->
            0

        StandUp _ ->
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

        KnockedOut ->
            Nothing

        Heal _ ->
            Nothing

        StandUp _ ->
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
