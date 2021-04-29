module Evergreen.V78.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V78.Data.Auth
import Evergreen.V78.Data.HealthStatus
import Evergreen.V78.Data.Item
import Evergreen.V78.Data.Map
import Evergreen.V78.Data.Message
import Evergreen.V78.Data.Perk
import Evergreen.V78.Data.Player.PlayerName
import Evergreen.V78.Data.Skill
import Evergreen.V78.Data.Special
import Evergreen.V78.Data.Trait
import Evergreen.V78.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V78.Data.Xp.Level
    , name : Evergreen.V78.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V78.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V78.Data.Xp.Xp
    , name : Evergreen.V78.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V78.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V78.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V78.Data.Perk.Perk Int
    , messages : List Evergreen.V78.Data.Message.Message
    , items : Dict.Dict Evergreen.V78.Data.Item.Id Evergreen.V78.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V78.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V78.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V78.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V78.Data.Auth.Auth Evergreen.V78.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V78.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V78.Data.Auth.Password Evergreen.V78.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V78.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V78.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V78.Data.Perk.Perk Int
    , messages : List Evergreen.V78.Data.Message.Message
    , items : Dict.Dict Evergreen.V78.Data.Item.Id Evergreen.V78.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V78.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V78.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V78.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
