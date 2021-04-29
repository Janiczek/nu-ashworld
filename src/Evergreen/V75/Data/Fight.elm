module Evergreen.V75.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V75.Data.Enemy
import Evergreen.V75.Data.Fight.ShotType
import Evergreen.V75.Data.Perk
import Evergreen.V75.Data.Player.PlayerName
import Evergreen.V75.Data.Skill
import Evergreen.V75.Data.Special
import Evergreen.V75.Data.Trait
import Evergreen.V75.Logic


type OpponentType
    = Npc Evergreen.V75.Data.Enemy.Type
    | Player Evergreen.V75.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V75.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V75.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V75.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V75.Data.Perk.Perk Int
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V75.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V75.Data.Skill.Skill Int
    , baseSpecial : Evergreen.V75.Data.Special.Special
    }
