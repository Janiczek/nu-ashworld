module Evergreen.V79.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V79.Data.Auth
import Evergreen.V79.Data.HealthStatus
import Evergreen.V79.Data.Item
import Evergreen.V79.Data.Map
import Evergreen.V79.Data.Message
import Evergreen.V79.Data.Perk
import Evergreen.V79.Data.Player.PlayerName
import Evergreen.V79.Data.Skill
import Evergreen.V79.Data.Special
import Evergreen.V79.Data.Trait
import Evergreen.V79.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V79.Data.Xp.Level
    , name : Evergreen.V79.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V79.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V79.Data.Xp.Xp
    , name : Evergreen.V79.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V79.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V79.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V79.Data.Perk.Perk Int
    , messages : List Evergreen.V79.Data.Message.Message
    , items : Dict.Dict Evergreen.V79.Data.Item.Id Evergreen.V79.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V79.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V79.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V79.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V79.Data.Auth.Auth Evergreen.V79.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V79.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V79.Data.Auth.Password Evergreen.V79.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V79.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V79.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V79.Data.Perk.Perk Int
    , messages : List Evergreen.V79.Data.Message.Message
    , items : Dict.Dict Evergreen.V79.Data.Item.Id Evergreen.V79.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V79.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V79.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V79.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
