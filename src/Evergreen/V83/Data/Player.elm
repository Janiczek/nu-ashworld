module Evergreen.V83.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V83.Data.Auth
import Evergreen.V83.Data.HealthStatus
import Evergreen.V83.Data.Item
import Evergreen.V83.Data.Map
import Evergreen.V83.Data.Message
import Evergreen.V83.Data.Perk
import Evergreen.V83.Data.Player.PlayerName
import Evergreen.V83.Data.Skill
import Evergreen.V83.Data.Special
import Evergreen.V83.Data.Trait
import Evergreen.V83.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V83.Data.Xp.Level
    , name : Evergreen.V83.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V83.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V83.Data.Xp.Xp
    , name : Evergreen.V83.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V83.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V83.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V83.Data.Perk.Perk Int
    , messages : List Evergreen.V83.Data.Message.Message
    , items : Dict.Dict Evergreen.V83.Data.Item.Id Evergreen.V83.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V83.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V83.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V83.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V83.Data.Item.Item
    }


type Player a
    = NeedsCharCreated (Evergreen.V83.Data.Auth.Auth Evergreen.V83.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V83.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V83.Data.Auth.Password Evergreen.V83.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V83.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V83.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V83.Data.Perk.Perk Int
    , messages : List Evergreen.V83.Data.Message.Message
    , items : Dict.Dict Evergreen.V83.Data.Item.Id Evergreen.V83.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V83.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V83.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V83.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V83.Data.Item.Item
    }
