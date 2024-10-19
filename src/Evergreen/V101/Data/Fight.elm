module Evergreen.V101.Data.Fight exposing (..)

import Dict
import Evergreen.V101.Data.Enemy
import Evergreen.V101.Data.Fight.ShotType
import Evergreen.V101.Data.FightStrategy
import Evergreen.V101.Data.Item
import Evergreen.V101.Data.Perk
import Evergreen.V101.Data.Player.PlayerName
import Evergreen.V101.Data.Skill
import Evergreen.V101.Data.Special
import Evergreen.V101.Data.Trait
import Evergreen.V101.Logic
import SeqDict
import SeqSet


type alias PlayerOpponent =
    { name : Evergreen.V101.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V101.Data.Enemy.Type
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
        , shotType : Evergreen.V101.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V101.Data.Fight.ShotType.ShotType
        }
    | Heal
        { itemKind : Evergreen.V101.Data.Item.Kind
        , healedHp : Int
        , newHp : Int
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V101.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V101.Data.Item.Item
        }
    | TargetAlreadyDead
    | BothDead
    | NobodyDead
    | NobodyDeadGivenUp


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
    , traits : SeqSet.SeqSet Evergreen.V101.Data.Trait.Trait
    , perks : SeqDict.SeqDict Evergreen.V101.Data.Perk.Perk Int
    , caps : Int
    , items : Dict.Dict Evergreen.V101.Data.Item.Id Evergreen.V101.Data.Item.Item
    , drops : List Evergreen.V101.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V101.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V101.Logic.AttackStats
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V101.Data.Skill.Skill Int
    , special : Evergreen.V101.Data.Special.Special
    , fightStrategy : Evergreen.V101.Data.FightStrategy.FightStrategy
    }
