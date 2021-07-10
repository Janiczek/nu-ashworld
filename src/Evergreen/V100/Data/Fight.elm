module Evergreen.V100.Data.Fight exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V100.Data.Enemy
import Evergreen.V100.Data.Fight.ShotType
import Evergreen.V100.Data.FightStrategy
import Evergreen.V100.Data.Item
import Evergreen.V100.Data.Perk
import Evergreen.V100.Data.Player.PlayerName
import Evergreen.V100.Data.Skill
import Evergreen.V100.Data.Special
import Evergreen.V100.Data.Trait
import Evergreen.V100.Logic


type alias PlayerOpponent =
    { name : Evergreen.V100.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V100.Data.Enemy.Type
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
        , shotType : Evergreen.V100.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V100.Data.Fight.ShotType.ShotType
        }
    | Heal
        { itemKind : Evergreen.V100.Data.Item.Kind
        , healedHp : Int
        , newHp : Int
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V100.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V100.Data.Item.Item
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
    , traits : AssocSet.Set Evergreen.V100.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V100.Data.Perk.Perk Int
    , caps : Int
    , items : Dict.Dict Evergreen.V100.Data.Item.Id Evergreen.V100.Data.Item.Item
    , drops : List Evergreen.V100.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V100.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V100.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V100.Data.Skill.Skill Int
    , special : Evergreen.V100.Data.Special.Special
    , fightStrategy : Evergreen.V100.Data.FightStrategy.FightStrategy
    }
