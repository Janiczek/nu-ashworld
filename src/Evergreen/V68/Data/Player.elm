module Evergreen.V68.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V68.Data.Auth
import Evergreen.V68.Data.HealthStatus
import Evergreen.V68.Data.Item
import Evergreen.V68.Data.Map
import Evergreen.V68.Data.Message
import Evergreen.V68.Data.Perk
import Evergreen.V68.Data.Player.PlayerName
import Evergreen.V68.Data.Skill
import Evergreen.V68.Data.Special
import Evergreen.V68.Data.Trait
import Evergreen.V68.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V68.Data.Xp.Level
    , name : Evergreen.V68.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V68.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V68.Data.Xp.Xp
    , name : Evergreen.V68.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V68.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V68.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V68.Data.Perk.Perk Int
    , messages : List Evergreen.V68.Data.Message.Message
    , items : Dict.Dict Evergreen.V68.Data.Item.Id Evergreen.V68.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V68.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V68.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V68.Data.Skill.Skill
    , availableSkillPoints : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V68.Data.Auth.Auth Evergreen.V68.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V68.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V68.Data.Auth.Password Evergreen.V68.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V68.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V68.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V68.Data.Perk.Perk Int
    , messages : List Evergreen.V68.Data.Message.Message
    , items : Dict.Dict Evergreen.V68.Data.Item.Id Evergreen.V68.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V68.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V68.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V68.Data.Skill.Skill
    , availableSkillPoints : Int
    }
