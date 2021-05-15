module Evergreen.V89.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V89.Data.Auth
import Evergreen.V89.Data.HealthStatus
import Evergreen.V89.Data.Item
import Evergreen.V89.Data.Map
import Evergreen.V89.Data.Message
import Evergreen.V89.Data.Perk
import Evergreen.V89.Data.Player.PlayerName
import Evergreen.V89.Data.Skill
import Evergreen.V89.Data.Special
import Evergreen.V89.Data.Trait
import Evergreen.V89.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V89.Data.Xp.Level
    , name : Evergreen.V89.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V89.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V89.Data.Xp.Xp
    , name : Evergreen.V89.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V89.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V89.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V89.Data.Perk.Perk Int
    , messages : List Evergreen.V89.Data.Message.Message
    , items : Dict.Dict Evergreen.V89.Data.Item.Id Evergreen.V89.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V89.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V89.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V89.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V89.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V89.Data.Auth.Auth Evergreen.V89.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V89.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V89.Data.Auth.Password Evergreen.V89.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V89.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V89.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V89.Data.Perk.Perk Int
    , messages : List Evergreen.V89.Data.Message.Message
    , items : Dict.Dict Evergreen.V89.Data.Item.Id Evergreen.V89.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V89.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V89.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V89.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V89.Data.Item.Item
    }
