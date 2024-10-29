module Evergreen.V112.Data.Player exposing (..)

import Dict
import Evergreen.V112.Data.Auth
import Evergreen.V112.Data.FightStrategy
import Evergreen.V112.Data.HealthStatus
import Evergreen.V112.Data.Item
import Evergreen.V112.Data.Item.Kind
import Evergreen.V112.Data.Map
import Evergreen.V112.Data.Message
import Evergreen.V112.Data.Perk
import Evergreen.V112.Data.Player.PlayerName
import Evergreen.V112.Data.Quest
import Evergreen.V112.Data.Skill
import Evergreen.V112.Data.Special
import Evergreen.V112.Data.Trait
import Evergreen.V112.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V112.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V112.Data.Auth.Password Evergreen.V112.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V112.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V112.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V112.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V112.Data.Message.Id Evergreen.V112.Data.Message.Message
    , items : Dict.Dict Evergreen.V112.Data.Item.Id Evergreen.V112.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V112.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V112.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V112.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V112.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V112.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V112.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V112.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V112.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V112.Data.Auth.Auth Evergreen.V112.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V112.Data.Xp.Xp
    , name : Evergreen.V112.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V112.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V112.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V112.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V112.Data.Message.Id Evergreen.V112.Data.Message.Message
    , items : Dict.Dict Evergreen.V112.Data.Item.Id Evergreen.V112.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V112.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V112.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V112.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V112.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V112.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V112.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V112.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V112.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V112.Data.Xp.Level
    , name : Evergreen.V112.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V112.Data.HealthStatus.HealthStatus
    }
