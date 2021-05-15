module Evergreen.V88.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V88.Data.Auth
import Evergreen.V88.Data.HealthStatus
import Evergreen.V88.Data.Item
import Evergreen.V88.Data.Map
import Evergreen.V88.Data.Message
import Evergreen.V88.Data.Perk
import Evergreen.V88.Data.Player.PlayerName
import Evergreen.V88.Data.Skill
import Evergreen.V88.Data.Special
import Evergreen.V88.Data.Trait
import Evergreen.V88.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V88.Data.Xp.Level
    , name : Evergreen.V88.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V88.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V88.Data.Xp.Xp
    , name : Evergreen.V88.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V88.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V88.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V88.Data.Perk.Perk Int
    , messages : List Evergreen.V88.Data.Message.Message
    , items : Dict.Dict Evergreen.V88.Data.Item.Id Evergreen.V88.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V88.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V88.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V88.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V88.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V88.Data.Auth.Auth Evergreen.V88.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V88.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V88.Data.Auth.Password Evergreen.V88.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V88.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V88.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V88.Data.Perk.Perk Int
    , messages : List Evergreen.V88.Data.Message.Message
    , items : Dict.Dict Evergreen.V88.Data.Item.Id Evergreen.V88.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V88.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V88.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V88.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V88.Data.Item.Item
    }
