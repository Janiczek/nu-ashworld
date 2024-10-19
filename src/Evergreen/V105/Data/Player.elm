module Evergreen.V105.Data.Player exposing (..)

import Dict
import Evergreen.V105.Data.Auth
import Evergreen.V105.Data.FightStrategy
import Evergreen.V105.Data.HealthStatus
import Evergreen.V105.Data.Item
import Evergreen.V105.Data.Item.Kind
import Evergreen.V105.Data.Map
import Evergreen.V105.Data.Message
import Evergreen.V105.Data.Perk
import Evergreen.V105.Data.Player.PlayerName
import Evergreen.V105.Data.Quest
import Evergreen.V105.Data.Skill
import Evergreen.V105.Data.Special
import Evergreen.V105.Data.Trait
import Evergreen.V105.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V105.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V105.Data.Auth.Password Evergreen.V105.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V105.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V105.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V105.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V105.Data.Message.Id Evergreen.V105.Data.Message.Message
    , items : Dict.Dict Evergreen.V105.Data.Item.Id Evergreen.V105.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V105.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V105.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V105.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V105.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V105.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V105.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V105.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V105.Data.Quest.Name
    }


type Player a
    = NeedsCharCreated (Evergreen.V105.Data.Auth.Auth Evergreen.V105.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V105.Data.Xp.Xp
    , name : Evergreen.V105.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V105.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V105.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V105.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V105.Data.Message.Id Evergreen.V105.Data.Message.Message
    , items : Dict.Dict Evergreen.V105.Data.Item.Id Evergreen.V105.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V105.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V105.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V105.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V105.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V105.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V105.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V105.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V105.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V105.Data.Xp.Level
    , name : Evergreen.V105.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V105.Data.HealthStatus.HealthStatus
    }
