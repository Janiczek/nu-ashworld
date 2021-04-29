module Evergreen.V77.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V77.Data.Enemy
import Evergreen.V77.Data.Fight.ShotType
import Evergreen.V77.Data.Perk
import Evergreen.V77.Data.Player.PlayerName
import Evergreen.V77.Data.Skill
import Evergreen.V77.Data.Special
import Evergreen.V77.Data.Trait
import Evergreen.V77.Logic


type OpponentType
    = Npc Evergreen.V77.Data.Enemy.Type
    | Player Evergreen.V77.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V77.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V77.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V77.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V77.Data.Perk.Perk Int
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V77.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V77.Data.Skill.Skill Int
    , baseSpecial : Evergreen.V77.Data.Special.Special
    }
