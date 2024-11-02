module Evergreen.V120.Data.Player exposing (..)

import Dict
import Evergreen.V120.Data.Auth
import Evergreen.V120.Data.FightStrategy
import Evergreen.V120.Data.HealthStatus
import Evergreen.V120.Data.Item
import Evergreen.V120.Data.Item.Kind
import Evergreen.V120.Data.Map
import Evergreen.V120.Data.Message
import Evergreen.V120.Data.Perk
import Evergreen.V120.Data.Player.PlayerName
import Evergreen.V120.Data.Quest
import Evergreen.V120.Data.Skill
import Evergreen.V120.Data.Special
import Evergreen.V120.Data.Trait
import Evergreen.V120.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V120.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V120.Data.Auth.Password Evergreen.V120.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V120.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V120.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V120.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V120.Data.Message.Id Evergreen.V120.Data.Message.Message
    , items : Dict.Dict Evergreen.V120.Data.Item.Id Evergreen.V120.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V120.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V120.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V120.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V120.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V120.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V120.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V120.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V120.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V120.Data.Auth.Auth Evergreen.V120.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V120.Data.Xp.Xp
    , name : Evergreen.V120.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V120.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V120.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V120.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V120.Data.Message.Id Evergreen.V120.Data.Message.Message
    , items : Dict.Dict Evergreen.V120.Data.Item.Id Evergreen.V120.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V120.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V120.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V120.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V120.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V120.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V120.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V120.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V120.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V120.Data.Xp.Level
    , name : Evergreen.V120.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V120.Data.HealthStatus.HealthStatus
    }
