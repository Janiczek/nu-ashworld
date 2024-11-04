module Evergreen.V123.Data.Player exposing (..)

import Dict
import Evergreen.V123.Data.Auth
import Evergreen.V123.Data.FightStrategy
import Evergreen.V123.Data.HealthStatus
import Evergreen.V123.Data.Item
import Evergreen.V123.Data.Item.Kind
import Evergreen.V123.Data.Map
import Evergreen.V123.Data.Message
import Evergreen.V123.Data.Perk
import Evergreen.V123.Data.Player.PlayerName
import Evergreen.V123.Data.Quest
import Evergreen.V123.Data.Skill
import Evergreen.V123.Data.Special
import Evergreen.V123.Data.Trait
import Evergreen.V123.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V123.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V123.Data.Auth.Password Evergreen.V123.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V123.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V123.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V123.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V123.Data.Message.Id Evergreen.V123.Data.Message.Message
    , items : Dict.Dict Evergreen.V123.Data.Item.Id Evergreen.V123.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V123.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V123.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V123.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V123.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V123.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V123.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V123.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V123.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V123.Data.Auth.Auth Evergreen.V123.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V123.Data.Xp.Xp
    , name : Evergreen.V123.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V123.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V123.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V123.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V123.Data.Message.Id Evergreen.V123.Data.Message.Message
    , items : Dict.Dict Evergreen.V123.Data.Item.Id Evergreen.V123.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V123.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V123.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V123.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V123.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V123.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V123.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V123.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V123.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V123.Data.Xp.Level
    , name : Evergreen.V123.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V123.Data.HealthStatus.HealthStatus
    }
