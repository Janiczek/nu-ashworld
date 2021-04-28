module Evergreen.V69.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V69.Data.Auth
import Evergreen.V69.Data.HealthStatus
import Evergreen.V69.Data.Item
import Evergreen.V69.Data.Map
import Evergreen.V69.Data.Message
import Evergreen.V69.Data.Perk
import Evergreen.V69.Data.Player.PlayerName
import Evergreen.V69.Data.Skill
import Evergreen.V69.Data.Special
import Evergreen.V69.Data.Trait
import Evergreen.V69.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V69.Data.Xp.Level
    , name : Evergreen.V69.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V69.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V69.Data.Xp.Xp
    , name : Evergreen.V69.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V69.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V69.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V69.Data.Perk.Perk Int
    , messages : List Evergreen.V69.Data.Message.Message
    , items : Dict.Dict Evergreen.V69.Data.Item.Id Evergreen.V69.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V69.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V69.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V69.Data.Skill.Skill
    , availableSkillPoints : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V69.Data.Auth.Auth Evergreen.V69.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V69.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V69.Data.Auth.Password Evergreen.V69.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V69.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V69.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V69.Data.Perk.Perk Int
    , messages : List Evergreen.V69.Data.Message.Message
    , items : Dict.Dict Evergreen.V69.Data.Item.Id Evergreen.V69.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V69.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V69.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V69.Data.Skill.Skill
    , availableSkillPoints : Int
    }
