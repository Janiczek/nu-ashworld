module Evergreen.V118.Data.Player exposing (..)

import Dict
import Evergreen.V118.Data.Auth
import Evergreen.V118.Data.FightStrategy
import Evergreen.V118.Data.HealthStatus
import Evergreen.V118.Data.Item
import Evergreen.V118.Data.Item.Kind
import Evergreen.V118.Data.Map
import Evergreen.V118.Data.Message
import Evergreen.V118.Data.Perk
import Evergreen.V118.Data.Player.PlayerName
import Evergreen.V118.Data.Quest
import Evergreen.V118.Data.Skill
import Evergreen.V118.Data.Special
import Evergreen.V118.Data.Trait
import Evergreen.V118.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V118.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V118.Data.Auth.Password Evergreen.V118.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V118.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V118.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V118.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V118.Data.Message.Id Evergreen.V118.Data.Message.Message
    , items : Dict.Dict Evergreen.V118.Data.Item.Id Evergreen.V118.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V118.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V118.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V118.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V118.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V118.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V118.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V118.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V118.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V118.Data.Auth.Auth Evergreen.V118.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V118.Data.Xp.Xp
    , name : Evergreen.V118.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V118.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V118.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V118.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V118.Data.Message.Id Evergreen.V118.Data.Message.Message
    , items : Dict.Dict Evergreen.V118.Data.Item.Id Evergreen.V118.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V118.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V118.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V118.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V118.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V118.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V118.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V118.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V118.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V118.Data.Xp.Level
    , name : Evergreen.V118.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V118.Data.HealthStatus.HealthStatus
    }
