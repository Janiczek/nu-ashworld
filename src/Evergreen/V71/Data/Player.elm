module Evergreen.V71.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V71.Data.Auth
import Evergreen.V71.Data.HealthStatus
import Evergreen.V71.Data.Item
import Evergreen.V71.Data.Map
import Evergreen.V71.Data.Message
import Evergreen.V71.Data.Perk
import Evergreen.V71.Data.Player.PlayerName
import Evergreen.V71.Data.Skill
import Evergreen.V71.Data.Special
import Evergreen.V71.Data.Trait
import Evergreen.V71.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V71.Data.Xp.Level
    , name : Evergreen.V71.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V71.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V71.Data.Xp.Xp
    , name : Evergreen.V71.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V71.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V71.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V71.Data.Perk.Perk Int
    , messages : List Evergreen.V71.Data.Message.Message
    , items : Dict.Dict Evergreen.V71.Data.Item.Id Evergreen.V71.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V71.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V71.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V71.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V71.Data.Auth.Auth Evergreen.V71.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V71.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V71.Data.Auth.Password Evergreen.V71.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V71.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V71.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V71.Data.Perk.Perk Int
    , messages : List Evergreen.V71.Data.Message.Message
    , items : Dict.Dict Evergreen.V71.Data.Item.Id Evergreen.V71.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V71.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V71.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V71.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
