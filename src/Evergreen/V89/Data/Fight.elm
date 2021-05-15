module Evergreen.V89.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V89.Data.Enemy
import Evergreen.V89.Data.Fight.ShotType
import Evergreen.V89.Data.Item
import Evergreen.V89.Data.Perk
import Evergreen.V89.Data.Player.PlayerName
import Evergreen.V89.Data.Skill
import Evergreen.V89.Data.Special
import Evergreen.V89.Data.Trait
import Evergreen.V89.Logic


type OpponentType
    = Npc Evergreen.V89.Data.Enemy.Type
    | Player Evergreen.V89.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V89.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V89.Data.Fight.ShotType.ShotType
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V89.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V89.Data.Item.Item
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
    , traits : AssocSet.Set Evergreen.V89.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V89.Data.Perk.Perk Int
    , caps : Int
    , drops : List Evergreen.V89.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V89.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V89.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V89.Data.Skill.Skill Int
    , special : Evergreen.V89.Data.Special.Special
    }
