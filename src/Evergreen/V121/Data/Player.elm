module Evergreen.V121.Data.Player exposing (..)

import Dict
import Evergreen.V121.Data.Auth
import Evergreen.V121.Data.FightStrategy
import Evergreen.V121.Data.HealthStatus
import Evergreen.V121.Data.Item
import Evergreen.V121.Data.Item.Kind
import Evergreen.V121.Data.Map
import Evergreen.V121.Data.Message
import Evergreen.V121.Data.Perk
import Evergreen.V121.Data.Player.PlayerName
import Evergreen.V121.Data.Quest
import Evergreen.V121.Data.Skill
import Evergreen.V121.Data.Special
import Evergreen.V121.Data.Trait
import Evergreen.V121.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V121.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V121.Data.Auth.Password Evergreen.V121.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V121.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V121.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V121.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V121.Data.Message.Id Evergreen.V121.Data.Message.Message
    , items : Dict.Dict Evergreen.V121.Data.Item.Id Evergreen.V121.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V121.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V121.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V121.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V121.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V121.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V121.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V121.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V121.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V121.Data.Auth.Auth Evergreen.V121.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V121.Data.Xp.Xp
    , name : Evergreen.V121.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V121.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V121.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V121.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V121.Data.Message.Id Evergreen.V121.Data.Message.Message
    , items : Dict.Dict Evergreen.V121.Data.Item.Id Evergreen.V121.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V121.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V121.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V121.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V121.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V121.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V121.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V121.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V121.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V121.Data.Xp.Level
    , name : Evergreen.V121.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V121.Data.HealthStatus.HealthStatus
    }
