module Evergreen.V70.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V70.Data.Auth
import Evergreen.V70.Data.HealthStatus
import Evergreen.V70.Data.Item
import Evergreen.V70.Data.Map
import Evergreen.V70.Data.Message
import Evergreen.V70.Data.Perk
import Evergreen.V70.Data.Player.PlayerName
import Evergreen.V70.Data.Skill
import Evergreen.V70.Data.Special
import Evergreen.V70.Data.Trait
import Evergreen.V70.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V70.Data.Xp.Level
    , name : Evergreen.V70.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V70.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V70.Data.Xp.Xp
    , name : Evergreen.V70.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V70.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V70.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V70.Data.Perk.Perk Int
    , messages : List Evergreen.V70.Data.Message.Message
    , items : Dict.Dict Evergreen.V70.Data.Item.Id Evergreen.V70.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V70.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V70.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V70.Data.Skill.Skill
    , availableSkillPoints : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V70.Data.Auth.Auth Evergreen.V70.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V70.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V70.Data.Auth.Password Evergreen.V70.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V70.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V70.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V70.Data.Perk.Perk Int
    , messages : List Evergreen.V70.Data.Message.Message
    , items : Dict.Dict Evergreen.V70.Data.Item.Id Evergreen.V70.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V70.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V70.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V70.Data.Skill.Skill
    , availableSkillPoints : Int
    }
