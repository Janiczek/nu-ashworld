module Evergreen.V87.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V87.Data.Auth
import Evergreen.V87.Data.HealthStatus
import Evergreen.V87.Data.Item
import Evergreen.V87.Data.Map
import Evergreen.V87.Data.Message
import Evergreen.V87.Data.Perk
import Evergreen.V87.Data.Player.PlayerName
import Evergreen.V87.Data.Skill
import Evergreen.V87.Data.Special
import Evergreen.V87.Data.Trait
import Evergreen.V87.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V87.Data.Xp.Level
    , name : Evergreen.V87.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V87.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V87.Data.Xp.Xp
    , name : Evergreen.V87.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V87.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V87.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V87.Data.Perk.Perk Int
    , messages : List Evergreen.V87.Data.Message.Message
    , items : Dict.Dict Evergreen.V87.Data.Item.Id Evergreen.V87.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V87.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V87.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V87.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V87.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V87.Data.Auth.Auth Evergreen.V87.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V87.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V87.Data.Auth.Password Evergreen.V87.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V87.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V87.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V87.Data.Perk.Perk Int
    , messages : List Evergreen.V87.Data.Message.Message
    , items : Dict.Dict Evergreen.V87.Data.Item.Id Evergreen.V87.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V87.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V87.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V87.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V87.Data.Item.Item
    }
