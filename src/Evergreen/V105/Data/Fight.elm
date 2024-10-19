module Evergreen.V105.Data.Fight exposing (..)

import Evergreen.V105.Data.Fight.AttackStyle
import Evergreen.V105.Data.Fight.OpponentType
import Evergreen.V105.Data.Item
import Evergreen.V105.Data.Item.Kind


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
        , attackStyle : Evergreen.V105.Data.Fight.AttackStyle.AttackStyle
        , remainingHp : Int
        , isCritical : Bool
        , apCost : Int
        }
    | Miss
        { attackStyle : Evergreen.V105.Data.Fight.AttackStyle.AttackStyle
        , apCost : Int
        }
    | Heal
        { itemKind : Evergreen.V105.Data.Item.Kind.Kind
        , healedHp : Int
        , newHp : Int
        }
    | SkipTurn
    | FailToDoAnything CommandRejectionReason


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V105.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V105.Data.Item.Item
        }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead
    | NobodyDeadGivenUp


type alias Info =
    { attacker : Evergreen.V105.Data.Fight.OpponentType.OpponentType
    , target : Evergreen.V105.Data.Fight.OpponentType.OpponentType
    , log : List ( Who, Action )
    , result : Result
    }
