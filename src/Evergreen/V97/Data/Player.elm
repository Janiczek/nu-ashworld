module Evergreen.V97.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V97.Data.Auth
import Evergreen.V97.Data.HealthStatus
import Evergreen.V97.Data.Item
import Evergreen.V97.Data.Map
import Evergreen.V97.Data.Message
import Evergreen.V97.Data.Perk
import Evergreen.V97.Data.Player.PlayerName
import Evergreen.V97.Data.Skill
import Evergreen.V97.Data.Special
import Evergreen.V97.Data.Trait
import Evergreen.V97.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V97.Data.Xp.Level
    , name : Evergreen.V97.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V97.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V97.Data.Xp.Xp
    , name : Evergreen.V97.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V97.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V97.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V97.Data.Perk.Perk Int
    , messages : List Evergreen.V97.Data.Message.Message
    , items : Dict.Dict Evergreen.V97.Data.Item.Id Evergreen.V97.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V97.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V97.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V97.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V97.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V97.Data.Auth.Auth Evergreen.V97.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V97.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V97.Data.Auth.Password Evergreen.V97.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V97.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V97.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V97.Data.Perk.Perk Int
    , messages : List Evergreen.V97.Data.Message.Message
    , items : Dict.Dict Evergreen.V97.Data.Item.Id Evergreen.V97.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V97.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V97.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V97.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V97.Data.Item.Item
    }
