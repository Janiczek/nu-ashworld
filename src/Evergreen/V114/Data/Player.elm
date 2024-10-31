module Evergreen.V114.Data.Player exposing (..)

import Dict
import Evergreen.V114.Data.Auth
import Evergreen.V114.Data.FightStrategy
import Evergreen.V114.Data.HealthStatus
import Evergreen.V114.Data.Item
import Evergreen.V114.Data.Item.Kind
import Evergreen.V114.Data.Map
import Evergreen.V114.Data.Message
import Evergreen.V114.Data.Perk
import Evergreen.V114.Data.Player.PlayerName
import Evergreen.V114.Data.Quest
import Evergreen.V114.Data.Skill
import Evergreen.V114.Data.Special
import Evergreen.V114.Data.Trait
import Evergreen.V114.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V114.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V114.Data.Auth.Password Evergreen.V114.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V114.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V114.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V114.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V114.Data.Message.Id Evergreen.V114.Data.Message.Message
    , items : Dict.Dict Evergreen.V114.Data.Item.Id Evergreen.V114.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V114.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V114.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V114.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V114.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V114.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V114.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V114.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V114.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V114.Data.Auth.Auth Evergreen.V114.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V114.Data.Xp.Xp
    , name : Evergreen.V114.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V114.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V114.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V114.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V114.Data.Message.Id Evergreen.V114.Data.Message.Message
    , items : Dict.Dict Evergreen.V114.Data.Item.Id Evergreen.V114.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V114.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V114.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V114.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V114.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V114.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V114.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V114.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V114.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V114.Data.Xp.Level
    , name : Evergreen.V114.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V114.Data.HealthStatus.HealthStatus
    }
