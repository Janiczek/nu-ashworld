module Evergreen.V75.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V75.Data.Auth
import Evergreen.V75.Data.HealthStatus
import Evergreen.V75.Data.Item
import Evergreen.V75.Data.Map
import Evergreen.V75.Data.Message
import Evergreen.V75.Data.Perk
import Evergreen.V75.Data.Player.PlayerName
import Evergreen.V75.Data.Skill
import Evergreen.V75.Data.Special
import Evergreen.V75.Data.Trait
import Evergreen.V75.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V75.Data.Xp.Level
    , name : Evergreen.V75.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V75.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V75.Data.Xp.Xp
    , name : Evergreen.V75.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V75.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V75.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V75.Data.Perk.Perk Int
    , messages : List Evergreen.V75.Data.Message.Message
    , items : Dict.Dict Evergreen.V75.Data.Item.Id Evergreen.V75.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V75.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V75.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V75.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V75.Data.Auth.Auth Evergreen.V75.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V75.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V75.Data.Auth.Password Evergreen.V75.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V75.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V75.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V75.Data.Perk.Perk Int
    , messages : List Evergreen.V75.Data.Message.Message
    , items : Dict.Dict Evergreen.V75.Data.Item.Id Evergreen.V75.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V75.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V75.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V75.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
