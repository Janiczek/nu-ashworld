module Evergreen.V69.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V69.Data.Enemy
import Evergreen.V69.Data.Fight.ShotType
import Evergreen.V69.Data.Player.PlayerName
import Evergreen.V69.Data.Skill
import Evergreen.V69.Data.Special
import Evergreen.V69.Data.Trait
import Evergreen.V69.Logic


type OpponentType
    = Npc Evergreen.V69.Data.Enemy.Type
    | Player Evergreen.V69.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V69.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V69.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V69.Data.Trait.Trait
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V69.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V69.Data.Skill.Skill Int
    , baseSpecial : Evergreen.V69.Data.Special.Special
    }
