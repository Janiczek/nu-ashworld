module Evergreen.V79.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V79.Data.Enemy
import Evergreen.V79.Data.Fight.ShotType
import Evergreen.V79.Data.Perk
import Evergreen.V79.Data.Player.PlayerName
import Evergreen.V79.Data.Skill
import Evergreen.V79.Data.Special
import Evergreen.V79.Data.Trait
import Evergreen.V79.Logic


type OpponentType
    = Npc Evergreen.V79.Data.Enemy.Type
    | Player Evergreen.V79.Data.Player.PlayerName.PlayerName


type Who
    = Attacker
    | Target


type FightAction
    = Start
        { distanceHexes : Int
        }
    | ComeCloser
        { hexes : Int
        , remainingDistanceHexes : Int
        }
    | Attack
        { damage : Int
        , shotType : Evergreen.V79.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V79.Data.Fight.ShotType.ShotType
        }


type FightResult
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


type alias FightInfo =
    { attacker : OpponentType
    , target : OpponentType
    , log : List ( Who, FightAction )
    , result : FightResult
    }


type alias Opponent =
    { type_ : OpponentType
    , hp : Int
    , maxHp : Int
    , maxAp : Int
    , sequence : Int
    , traits : AssocSet.Set Evergreen.V79.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V79.Data.Perk.Perk Int
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V79.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V79.Data.Skill.Skill Int
    , special : Evergreen.V79.Data.Special.Special
    }
