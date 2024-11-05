module Evergreen.V128.Data.Player exposing (..)

import Dict
import Evergreen.V128.Data.Auth
import Evergreen.V128.Data.FightStrategy
import Evergreen.V128.Data.HealthStatus
import Evergreen.V128.Data.Item
import Evergreen.V128.Data.Item.Kind
import Evergreen.V128.Data.Map
import Evergreen.V128.Data.Message
import Evergreen.V128.Data.Perk
import Evergreen.V128.Data.Player.PlayerName
import Evergreen.V128.Data.Quest
import Evergreen.V128.Data.Skill
import Evergreen.V128.Data.Special
import Evergreen.V128.Data.Trait
import Evergreen.V128.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V128.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V128.Data.Auth.Password Evergreen.V128.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V128.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V128.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V128.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V128.Data.Message.Id Evergreen.V128.Data.Message.Message
    , items : Dict.Dict Evergreen.V128.Data.Item.Id Evergreen.V128.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V128.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V128.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V128.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V128.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V128.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V128.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V128.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V128.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V128.Data.Auth.Auth Evergreen.V128.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V128.Data.Xp.Xp
    , name : Evergreen.V128.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V128.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V128.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V128.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V128.Data.Message.Id Evergreen.V128.Data.Message.Message
    , items : Dict.Dict Evergreen.V128.Data.Item.Id Evergreen.V128.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V128.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V128.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V128.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V128.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V128.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V128.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V128.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V128.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V128.Data.Xp.Level
    , name : Evergreen.V128.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V128.Data.HealthStatus.HealthStatus
    , location : Evergreen.V128.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V128.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V128.Data.Item.Kind.Kind
            }
    }
