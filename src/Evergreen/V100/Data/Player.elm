module Evergreen.V100.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V100.Data.Auth
import Evergreen.V100.Data.FightStrategy
import Evergreen.V100.Data.HealthStatus
import Evergreen.V100.Data.Item
import Evergreen.V100.Data.Map
import Evergreen.V100.Data.Message
import Evergreen.V100.Data.Perk
import Evergreen.V100.Data.Player.PlayerName
import Evergreen.V100.Data.Skill
import Evergreen.V100.Data.Special
import Evergreen.V100.Data.Trait
import Evergreen.V100.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V100.Data.Xp.Level
    , name : Evergreen.V100.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V100.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V100.Data.Xp.Xp
    , name : Evergreen.V100.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V100.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V100.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V100.Data.Perk.Perk Int
    , messages : List Evergreen.V100.Data.Message.Message
    , items : Dict.Dict Evergreen.V100.Data.Item.Id Evergreen.V100.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V100.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V100.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V100.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V100.Data.Item.Item
    , fightStrategy : Evergreen.V100.Data.FightStrategy.FightStrategy
    }


type Player a
    = NeedsCharCreated (Evergreen.V100.Data.Auth.Auth Evergreen.V100.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V100.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V100.Data.Auth.Password Evergreen.V100.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V100.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V100.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V100.Data.Perk.Perk Int
    , messages : List Evergreen.V100.Data.Message.Message
    , items : Dict.Dict Evergreen.V100.Data.Item.Id Evergreen.V100.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V100.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V100.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V100.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V100.Data.Item.Item
    , fightStrategy : Evergreen.V100.Data.FightStrategy.FightStrategy
    }
