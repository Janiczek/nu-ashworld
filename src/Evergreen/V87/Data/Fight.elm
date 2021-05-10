module Evergreen.V87.Data.Fight exposing (..)

import AssocList
import AssocSet
import Evergreen.V87.Data.Enemy
import Evergreen.V87.Data.Fight.ShotType
import Evergreen.V87.Data.Item
import Evergreen.V87.Data.Perk
import Evergreen.V87.Data.Player.PlayerName
import Evergreen.V87.Data.Skill
import Evergreen.V87.Data.Special
import Evergreen.V87.Data.Trait
import Evergreen.V87.Logic


type OpponentType
    = Npc Evergreen.V87.Data.Enemy.Type
    | Player Evergreen.V87.Data.Player.PlayerName.PlayerName


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
        , shotType : Evergreen.V87.Data.Fight.ShotType.ShotType
        , remainingHp : Int
        , isCritical : Bool
        }
    | Miss
        { shotType : Evergreen.V87.Data.Fight.ShotType.ShotType
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
    , traits : AssocSet.Set Evergreen.V87.Data.Trait.Trait
    , perks : AssocList.Dict Evergreen.V87.Data.Perk.Perk Int
    , caps : Int
    , equippedArmor : Maybe Evergreen.V87.Data.Item.Kind
    , naturalArmorClass : Int
    , attackStats : Evergreen.V87.Logic.AttackStats
    , addedSkillPercentages : AssocList.Dict Evergreen.V87.Data.Skill.Skill Int
    , special : Evergreen.V87.Data.Special.Special
    }
