module Evergreen.V96.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V96.Data.Enemy
import Evergreen.V96.Data.Fight.ShotType
import Evergreen.V96.Data.Item
import Evergreen.V96.Data.Perk
import Evergreen.V96.Data.Player.PlayerName
import Evergreen.V96.Data.Skill
import Evergreen.V96.Data.Special
import Evergreen.V96.Data.Trait
import Evergreen.V96.Logic


type alias PlayerOpponent =
    { name : Evergreen.V96.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V96.Data.Enemy.Type
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
        , shotType : Evergreen.V96.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V96.Data.Fight.ShotType.ShotType
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V96.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V96.Data.Item.Item
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
    , traits : AssocSet.Set Evergreen.V96.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V96.Data.Perk.Perk Int
    , caps : Int
    , drops : List Evergreen.V96.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V96.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V96.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V96.Data.Skill.Skill Int
    , special : Evergreen.V96.Data.Special.Special
    }
