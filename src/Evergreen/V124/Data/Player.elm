module Evergreen.V124.Data.Player exposing (..)

import Dict
import Evergreen.V124.Data.Auth
import Evergreen.V124.Data.FightStrategy
import Evergreen.V124.Data.HealthStatus
import Evergreen.V124.Data.Item
import Evergreen.V124.Data.Item.Kind
import Evergreen.V124.Data.Map
import Evergreen.V124.Data.Message
import Evergreen.V124.Data.Perk
import Evergreen.V124.Data.Player.PlayerName
import Evergreen.V124.Data.Quest
import Evergreen.V124.Data.Skill
import Evergreen.V124.Data.Special
import Evergreen.V124.Data.Trait
import Evergreen.V124.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V124.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V124.Data.Auth.Password Evergreen.V124.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V124.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V124.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V124.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V124.Data.Message.Id Evergreen.V124.Data.Message.Message
    , items : Dict.Dict Evergreen.V124.Data.Item.Id Evergreen.V124.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V124.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V124.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V124.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V124.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V124.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V124.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V124.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V124.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V124.Data.Auth.Auth Evergreen.V124.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V124.Data.Xp.Xp
    , name : Evergreen.V124.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V124.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V124.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V124.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V124.Data.Message.Id Evergreen.V124.Data.Message.Message
    , items : Dict.Dict Evergreen.V124.Data.Item.Id Evergreen.V124.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V124.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V124.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V124.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V124.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V124.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V124.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V124.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V124.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V124.Data.Xp.Level
    , name : Evergreen.V124.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V124.Data.HealthStatus.HealthStatus
    }
