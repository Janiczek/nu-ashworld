module Evergreen.V66.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V66.Data.Auth
import Evergreen.V66.Data.HealthStatus
import Evergreen.V66.Data.Item
import Evergreen.V66.Data.Map
import Evergreen.V66.Data.Message
import Evergreen.V66.Data.Perk
import Evergreen.V66.Data.Player.PlayerName
import Evergreen.V66.Data.Skill
import Evergreen.V66.Data.Special
import Evergreen.V66.Data.Trait
import Evergreen.V66.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V66.Data.Xp.Level
    , name : Evergreen.V66.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V66.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V66.Data.Xp.Xp
    , name : Evergreen.V66.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V66.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V66.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V66.Data.Perk.Perk Int
    , messages : List Evergreen.V66.Data.Message.Message
    , items : Dict.Dict Evergreen.V66.Data.Item.Id Evergreen.V66.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V66.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V66.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V66.Data.Skill.Skill
    , availableSkillPoints : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V66.Data.Auth.Auth Evergreen.V66.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V66.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V66.Data.Auth.Password Evergreen.V66.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V66.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V66.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V66.Data.Perk.Perk Int
    , messages : List Evergreen.V66.Data.Message.Message
    , items : Dict.Dict Evergreen.V66.Data.Item.Id Evergreen.V66.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V66.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V66.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V66.Data.Skill.Skill
    , availableSkillPoints : Int
    }
