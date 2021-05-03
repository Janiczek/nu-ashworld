module Evergreen.V83.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V83.Data.Enemy
import Evergreen.V83.Data.Fight.ShotType
import Evergreen.V83.Data.Item
import Evergreen.V83.Data.Perk
import Evergreen.V83.Data.Player.PlayerName
import Evergreen.V83.Data.Skill
import Evergreen.V83.Data.Special
import Evergreen.V83.Data.Trait
import Evergreen.V83.Logic


type OpponentType
    = Npc Evergreen.V83.Data.Enemy.Type
    | Player Evergreen.V83.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V83.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        }
    | Miss
        { shotType : Evergreen.V83.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V83.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V83.Data.Perk.Perk Int
    , caps : Int
    , equippedArmor : Maybe Evergreen.V83.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V83.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V83.Data.Skill.Skill Int
    , special : Evergreen.V83.Data.Special.Special
    }
