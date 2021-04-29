module Evergreen.V81.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V81.Data.Enemy
import Evergreen.V81.Data.Fight.ShotType
import Evergreen.V81.Data.Perk
import Evergreen.V81.Data.Player.PlayerName
import Evergreen.V81.Data.Skill
import Evergreen.V81.Data.Special
import Evergreen.V81.Data.Trait
import Evergreen.V81.Logic


type OpponentType
    = Npc Evergreen.V81.Data.Enemy.Type
    | Player Evergreen.V81.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V81.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V81.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V81.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V81.Data.Perk.Perk Int
    , caps : Int
    , armorClass : Int
    , attackStats : Evergreen.V81.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V81.Data.Skill.Skill Int
    , special : Evergreen.V81.Data.Special.Special
    }
