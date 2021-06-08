module Evergreen.V97.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V97.Data.Enemy
import Evergreen.V97.Data.Fight.ShotType
import Evergreen.V97.Data.Item
import Evergreen.V97.Data.Perk
import Evergreen.V97.Data.Player.PlayerName
import Evergreen.V97.Data.Skill
import Evergreen.V97.Data.Special
import Evergreen.V97.Data.Trait
import Evergreen.V97.Logic


type alias PlayerOpponent =
    { name : Evergreen.V97.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V97.Data.Enemy.Type
    | Player PlayerOpponent


type Who
    = Attacker
    | Target


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
        , shotType : Evergreen.V97.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V97.Data.Fight.ShotType.ShotType
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V97.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V97.Data.Item.Item
        }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead


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
    , traits : AssocSet.Set Evergreen.V97.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V97.Data.Perk.Perk Int
    , caps : Int
    , drops : List Evergreen.V97.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V97.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V97.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V97.Data.Skill.Skill Int
    , special : Evergreen.V97.Data.Special.Special
    }
