module Evergreen.V85.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V85.Data.Enemy
import Evergreen.V85.Data.Fight.ShotType
import Evergreen.V85.Data.Item
import Evergreen.V85.Data.Perk
import Evergreen.V85.Data.Player.PlayerName
import Evergreen.V85.Data.Skill
import Evergreen.V85.Data.Special
import Evergreen.V85.Data.Trait
import Evergreen.V85.Logic


type OpponentType
    = Npc Evergreen.V85.Data.Enemy.Type
    | Player Evergreen.V85.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V85.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V85.Data.Fight.ShotType.ShotType
        }


type Result
    = AttackerWon
        { xpGained : Int
        , capsGained : Int
        }
    | TargetWon
        { xpGained : Int
        , capsGained : Int
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
    , traits : AssocSet.Set Evergreen.V85.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V85.Data.Perk.Perk Int
    , caps : Int
    , equippedArmor : Maybe Evergreen.V85.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V85.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V85.Data.Skill.Skill Int
    , special : Evergreen.V85.Data.Special.Special
    }
