module Evergreen.V101.Data.Player exposing (..)

import AssocList
import Dict
import Evergreen.V101.Data.Auth
import Evergreen.V101.Data.FightStrategy
import Evergreen.V101.Data.HealthStatus
import Evergreen.V101.Data.Item
import Evergreen.V101.Data.Map
import Evergreen.V101.Data.Message
import Evergreen.V101.Data.Perk
import Evergreen.V101.Data.Player.PlayerName
import Evergreen.V101.Data.Skill
import Evergreen.V101.Data.Special
import Evergreen.V101.Data.Trait
import Evergreen.V101.Data.Xp
import SeqSet


type alias COtherPlayer =
    { level : Evergreen.V101.Data.Xp.Level
    , name : Evergreen.V101.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V101.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V101.Data.Xp.Xp
    , name : Evergreen.V101.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V101.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V101.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V101.Data.Perk.Perk Int
    , messages : List Evergreen.V101.Data.Message.Message
    , items : Dict.Dict Evergreen.V101.Data.Item.Id Evergreen.V101.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V101.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V101.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V101.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V101.Data.Item.Item
    , fightStrategy : Evergreen.V101.Data.FightStrategy.FightStrategy
    }


type Player a
    = NeedsCharCreated (Evergreen.V101.Data.Auth.Auth Evergreen.V101.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V101.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V101.Data.Auth.Password Evergreen.V101.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V101.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V101.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V101.Data.Perk.Perk Int
    , messages : List Evergreen.V101.Data.Message.Message
    , items : Dict.Dict Evergreen.V101.Data.Item.Id Evergreen.V101.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V101.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V101.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V101.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V101.Data.Item.Item
    , fightStrategy : Evergreen.V101.Data.FightStrategy.FightStrategy
    }
