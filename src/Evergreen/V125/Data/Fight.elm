module Evergreen.V125.Data.Fight exposing (..)

import Evergreen.V125.Data.Fight.AttackStyle
import Evergreen.V125.Data.Fight.Critical
import Evergreen.V125.Data.Fight.OpponentType
import Evergreen.V125.Data.Item
import Evergreen.V125.Data.Item.Kind


type Who
    = Attacker
    | Target


type CommandRejectionReason
    = Heal_ItemNotPresent
    | Heal_ItemDoesNotHeal
    | Heal_AlreadyFullyHealed
    | HealWithAnything_NoHealingItem
    | HealWithAnything_AlreadyFullyHealed
    | MoveForward_AlreadyNextToEachOther
    | Attack_NotCloseEnough
    | Attack_NotEnoughAP


type Action
    = Start
        { distanceHexes : Int
        }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , attackStyle : Evergreen.V125.Data.Fight.AttackStyle.AttackStyle
        , remainingHp : Int
        , critical : Maybe ( List Evergreen.V125.Data.Fight.Critical.Effect, Evergreen.V125.Data.Fight.Critical.Message )
        , apCost : Int
        }
    | Miss
        { attackStyle : Evergreen.V125.Data.Fight.AttackStyle.AttackStyle
        , apCost : Int
        }
    | Heal
        { itemKind : Evergreen.V125.Data.Item.Kind.Kind
        , healedHp : Int
        , newHp : Int
        }
    | SkipTurn
    | KnockedOut
    | StandUp
        { apCost : Int
        }
    | FailToDoAnything CommandRejectionReason


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V125.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V125.Data.Item.Item
        }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead
    | NobodyDeadGivenUp


type alias Equipment =
    { weapon : Maybe Evergreen.V125.Data.Item.Kind.Kind
    , armor : Maybe Evergreen.V125.Data.Item.Kind.Kind
    }


type alias Info =
    { attacker : Evergreen.V125.Data.Fight.OpponentType.OpponentType
    , target : Evergreen.V125.Data.Fight.OpponentType.OpponentType
    , log : List ( Who, Action )
    , result : Result
    , attackerEquipment : Maybe Equipment
    , targetEquipment : Maybe Equipment
    }