module Evergreen.V81.Data.Player exposing (..)

import AssocList
import AssocSet
import Dict
import Evergreen.V81.Data.Auth
import Evergreen.V81.Data.HealthStatus
import Evergreen.V81.Data.Item
import Evergreen.V81.Data.Map
import Evergreen.V81.Data.Message
import Evergreen.V81.Data.Perk
import Evergreen.V81.Data.Player.PlayerName
import Evergreen.V81.Data.Skill
import Evergreen.V81.Data.Special
import Evergreen.V81.Data.Trait
import Evergreen.V81.Data.Xp


type alias COtherPlayer =
    { level : Evergreen.V81.Data.Xp.Level
    , name : Evergreen.V81.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V81.Data.HealthStatus.HealthStatus
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V81.Data.Xp.Xp
    , name : Evergreen.V81.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V81.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V81.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V81.Data.Perk.Perk Int
    , messages : List Evergreen.V81.Data.Message.Message
    , items : Dict.Dict Evergreen.V81.Data.Item.Id Evergreen.V81.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V81.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V81.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V81.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V81.Data.Auth.Auth Evergreen.V81.Data.Auth.Verified)
    | Player a


type alias SPlayer =
    { name : Evergreen.V81.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V81.Data.Auth.Password Evergreen.V81.Data.Auth.Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V81.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V81.Data.Map.TileNum
    , perks : AssocList.Dict Evergreen.V81.Data.Perk.Perk Int
    , messages : List Evergreen.V81.Data.Message.Message
    , items : Dict.Dict Evergreen.V81.Data.Item.Id Evergreen.V81.Data.Item.Item
    , traits : AssocSet.Set Evergreen.V81.Data.Trait.Trait
    , addedSkillPercentages : AssocList.Dict Evergreen.V81.Data.Skill.Skill Int
    , taggedSkills : AssocSet.Set Evergreen.V81.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }
