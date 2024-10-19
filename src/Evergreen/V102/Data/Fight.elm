module Evergreen.V102.Data.Fight exposing (..)

import Dict
import Evergreen.V102.Data.Enemy
import Evergreen.V102.Data.Fight.ShotType
import Evergreen.V102.Data.FightStrategy
import Evergreen.V102.Data.Item
import Evergreen.V102.Data.Perk
import Evergreen.V102.Data.Player.PlayerName
import Evergreen.V102.Data.Skill
import Evergreen.V102.Data.Special
import Evergreen.V102.Data.Trait
import Evergreen.V102.Logic
import SeqDict
import SeqSet


type alias PlayerOpponent =
    { name : Evergreen.V102.Data.Player.PlayerName.PlayerName
    , xp : Int
    }


type OpponentType
    = Npc Evergreen.V102.Data.Enemy.Type
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
        , shotType : Evergreen.V102.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V102.Data.Fight.ShotType.ShotType
        }
    | Heal
        { itemKind : Evergreen.V102.Data.Item.Kind
        , healedHp : Int
        , newHp : Int
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V102.Data.Item.Item
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
        , itemsGained : List Evergreen.V102.Data.Item.Item
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
    , traits : SeqSet.SeqSet Evergreen.V102.Data.Trait.Trait
    , perks : SeqDict.SeqDict Evergreen.V102.Data.Perk.Perk Int
    , caps : Int
    , items : Dict.Dict Evergreen.V102.Data.Item.Id Evergreen.V102.Data.Item.Item
    , drops : List Evergreen.V102.Data.Item.Item
    , equippedArmor : Maybe Evergreen.V102.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V102.Logic.AttackStats
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V102.Data.Skill.Skill Int
    , special : Evergreen.V102.Data.Special.Special
    , fightStrategy : Evergreen.V102.Data.FightStrategy.FightStrategy
    }
