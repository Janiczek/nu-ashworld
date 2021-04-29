module Evergreen.V77.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V77.Data.Auth
import Evergreen.V77.Data.HealthStatus
import Evergreen.V77.Data.Item
import Evergreen.V77.Data.Map
import Evergreen.V77.Data.Message
import Evergreen.V77.Data.Perk
import Evergreen.V77.Data.Player.PlayerName
import Evergreen.V77.Data.Skill
import Evergreen.V77.Data.Special
import Evergreen.V77.Data.Trait
import Evergreen.V77.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V77.Data.Xp.Level
    , name : Evergreen.V77.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V77.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V77.Data.Xp.Xp
    , name : Evergreen.V77.Data.Player.PlayerName.PlayerName
    , baseSpecial : Evergreen.V77.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V77.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V77.Data.Perk.Perk Int
    , messages : List Evergreen.V77.Data.Message.Message
    , items : Dict.Dict Evergreen.V77.Data.Item.Id Evergreen.V77.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V77.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V77.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V77.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V77.Data.Auth.Auth Evergreen.V77.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V77.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V77.Data.Auth.Password Evergreen.V77.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , baseSpecial : Evergreen.V77.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V77.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V77.Data.Perk.Perk Int
    , messages : List Evergreen.V77.Data.Message.Message
    , items : Dict.Dict Evergreen.V77.Data.Item.Id Evergreen.V77.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V77.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V77.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V77.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
