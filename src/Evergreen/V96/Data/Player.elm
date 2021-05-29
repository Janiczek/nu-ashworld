module Evergreen.V96.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V96.Data.Auth
import Evergreen.V96.Data.HealthStatus
import Evergreen.V96.Data.Item
import Evergreen.V96.Data.Map
import Evergreen.V96.Data.Message
import Evergreen.V96.Data.Perk
import Evergreen.V96.Data.Player.PlayerName
import Evergreen.V96.Data.Skill
import Evergreen.V96.Data.Special
import Evergreen.V96.Data.Trait
import Evergreen.V96.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V96.Data.Xp.Level
    , name : Evergreen.V96.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V96.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V96.Data.Xp.Xp
    , name : Evergreen.V96.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V96.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V96.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V96.Data.Perk.Perk Int
    , messages : List Evergreen.V96.Data.Message.Message
    , items : Dict.Dict Evergreen.V96.Data.Item.Id Evergreen.V96.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V96.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V96.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V96.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V96.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V96.Data.Auth.Auth Evergreen.V96.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V96.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V96.Data.Auth.Password Evergreen.V96.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V96.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V96.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V96.Data.Perk.Perk Int
    , messages : List Evergreen.V96.Data.Message.Message
    , items : Dict.Dict Evergreen.V96.Data.Item.Id Evergreen.V96.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V96.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V96.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V96.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V96.Data.Item.Item
    }
