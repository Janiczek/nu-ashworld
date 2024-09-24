module Evergreen.V104.Data.Player exposing (..)

import AssocList
import SeqSet
import Dict
import Evergreen.V104.Data.Auth
import Evergreen.V104.Data.FightStrategy
import Evergreen.V104.Data.HealthStatus
import Evergreen.V104.Data.Item
import Evergreen.V104.Data.Map
import Evergreen.V104.Data.Message
import Evergreen.V104.Data.Perk
import Evergreen.V104.Data.Player.PlayerName
import Evergreen.V104.Data.Skill
import Evergreen.V104.Data.Special
import Evergreen.V104.Data.Trait
import Evergreen.V104.Data.Xp


type alias SPlayer =
    { name : Evergreen.V104.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V104.Data.Auth.Password Evergreen.V104.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V104.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V104.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V104.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V104.Data.Message.Id Evergreen.V104.Data.Message.Message
    , items : Dict.Dict Evergreen.V104.Data.Item.Id Evergreen.V104.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V104.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V104.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V104.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V104.Data.Item.Item
    , fightStrategy : Evergreen.V104.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    }


type Player a
    = NeedsCharCreated (Evergreen.V104.Data.Auth.Auth Evergreen.V104.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V104.Data.Xp.Xp
    , name : Evergreen.V104.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V104.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V104.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V104.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V104.Data.Message.Id Evergreen.V104.Data.Message.Message
    , items : Dict.Dict Evergreen.V104.Data.Item.Id Evergreen.V104.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V104.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V104.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V104.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V104.Data.Item.Item
    , fightStrategy : Evergreen.V104.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    }


type alias COtherPlayer =
    { level : Evergreen.V104.Data.Xp.Level
    , name : Evergreen.V104.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V104.Data.HealthStatus.HealthStatus
    }
