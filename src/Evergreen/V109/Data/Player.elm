module Evergreen.V109.Data.Player exposing (..)

import Dict
import Evergreen.V109.Data.Auth
import Evergreen.V109.Data.FightStrategy
import Evergreen.V109.Data.HealthStatus
import Evergreen.V109.Data.Item
import Evergreen.V109.Data.Item.Kind
import Evergreen.V109.Data.Map
import Evergreen.V109.Data.Message
import Evergreen.V109.Data.Perk
import Evergreen.V109.Data.Player.PlayerName
import Evergreen.V109.Data.Quest
import Evergreen.V109.Data.Skill
import Evergreen.V109.Data.Special
import Evergreen.V109.Data.Trait
import Evergreen.V109.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V109.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V109.Data.Auth.Password Evergreen.V109.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V109.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V109.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V109.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V109.Data.Message.Id Evergreen.V109.Data.Message.Message
    , items : Dict.Dict Evergreen.V109.Data.Item.Id Evergreen.V109.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V109.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V109.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V109.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V109.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V109.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V109.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V109.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V109.Data.Quest.Name
    }


type Player a
    = NeedsCharCreated (Evergreen.V109.Data.Auth.Auth Evergreen.V109.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V109.Data.Xp.Xp
    , name : Evergreen.V109.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V109.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V109.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V109.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V109.Data.Message.Id Evergreen.V109.Data.Message.Message
    , items : Dict.Dict Evergreen.V109.Data.Item.Id Evergreen.V109.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V109.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V109.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V109.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V109.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V109.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V109.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V109.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V109.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V109.Data.Xp.Level
    , name : Evergreen.V109.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V109.Data.HealthStatus.HealthStatus
    }
