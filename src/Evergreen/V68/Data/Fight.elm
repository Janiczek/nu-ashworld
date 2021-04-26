module Evergreen.V68.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V68.Data.Enemy
import Evergreen.V68.Data.Fight.ShotType
import Evergreen.V68.Data.Player.PlayerName
import Evergreen.V68.Data.Skill
import Evergreen.V68.Data.Special
import Evergreen.V68.Data.Trait
import Evergreen.V68.Logic


type OpponentType
    = Npc Evergreen.V68.Data.Enemy.Type
    | Player Evergreen.V68.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V68.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V68.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V68.Data.Trait.Trait
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V68.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V68.Data.Skill.Skill Int
    , baseSpecial : Evergreen.V68.Data.Special.Special
    }
