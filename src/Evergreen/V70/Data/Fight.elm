module Evergreen.V70.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V70.Data.Enemy
import Evergreen.V70.Data.Fight.ShotType
import Evergreen.V70.Data.Player.PlayerName
import Evergreen.V70.Data.Skill
import Evergreen.V70.Data.Special
import Evergreen.V70.Data.Trait
import Evergreen.V70.Logic


type OpponentType
    = Npc Evergreen.V70.Data.Enemy.Type
    | Player Evergreen.V70.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V70.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V70.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V70.Data.Trait.Trait
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V70.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V70.Data.Skill.Skill Int
    , baseSpecial : Evergreen.V70.Data.Special.Special
    }
