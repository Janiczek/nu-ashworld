module Evergreen.V85.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V85.Data.Auth
import Evergreen.V85.Data.HealthStatus
import Evergreen.V85.Data.Item
import Evergreen.V85.Data.Map
import Evergreen.V85.Data.Message
import Evergreen.V85.Data.Perk
import Evergreen.V85.Data.Player.PlayerName
import Evergreen.V85.Data.Skill
import Evergreen.V85.Data.Special
import Evergreen.V85.Data.Trait
import Evergreen.V85.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V85.Data.Xp.Level
    , name : Evergreen.V85.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V85.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V85.Data.Xp.Xp
    , name : Evergreen.V85.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V85.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V85.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V85.Data.Perk.Perk Int
    , messages : List Evergreen.V85.Data.Message.Message
    , items : Dict.Dict Evergreen.V85.Data.Item.Id Evergreen.V85.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V85.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V85.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V85.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V85.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V85.Data.Auth.Auth Evergreen.V85.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V85.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V85.Data.Auth.Password Evergreen.V85.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V85.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V85.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V85.Data.Perk.Perk Int
    , messages : List Evergreen.V85.Data.Message.Message
    , items : Dict.Dict Evergreen.V85.Data.Item.Id Evergreen.V85.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V85.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V85.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V85.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V85.Data.Item.Item
    }
