module Evergreen.V102.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V102.Data.Auth
import Evergreen.V102.Data.FightStrategy
import Evergreen.V102.Data.HealthStatus
import Evergreen.V102.Data.Item
import Evergreen.V102.Data.Map
import Evergreen.V102.Data.Message
import Evergreen.V102.Data.Perk
import Evergreen.V102.Data.Player.PlayerName
import Evergreen.V102.Data.Skill
import Evergreen.V102.Data.Special
import Evergreen.V102.Data.Trait
import Evergreen.V102.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V102.Data.Xp.Level
    , name : Evergreen.V102.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V102.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V102.Data.Xp.Xp
    , name : Evergreen.V102.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V102.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V102.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V102.Data.Perk.Perk Int
    , messages : List Evergreen.V102.Data.Message.Message
    , items : Dict.Dict Evergreen.V102.Data.Item.Id Evergreen.V102.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V102.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V102.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V102.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V102.Data.Item.Item
    , fightStrategy : Evergreen.V102.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    }


type Player a
    = NeedsCharCreated (Evergreen.V102.Data.Auth.Auth Evergreen.V102.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V102.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V102.Data.Auth.Password Evergreen.V102.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V102.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V102.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V102.Data.Perk.Perk Int
    , messages : List Evergreen.V102.Data.Message.Message
    , items : Dict.Dict Evergreen.V102.Data.Item.Id Evergreen.V102.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V102.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V102.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V102.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V102.Data.Item.Item
    , fightStrategy : Evergreen.V102.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    }
