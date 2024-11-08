module Evergreen.V135.Data.Player exposing (..)

import Dict
import Evergreen.V135.Data.Auth
import Evergreen.V135.Data.FightStrategy
import Evergreen.V135.Data.HealthStatus
import Evergreen.V135.Data.Item
import Evergreen.V135.Data.Item.Kind
import Evergreen.V135.Data.Map
import Evergreen.V135.Data.Message
import Evergreen.V135.Data.Perk
import Evergreen.V135.Data.Player.PlayerName
import Evergreen.V135.Data.Quest
import Evergreen.V135.Data.Skill
import Evergreen.V135.Data.Special
import Evergreen.V135.Data.Trait
import Evergreen.V135.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V135.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V135.Data.Auth.Password Evergreen.V135.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V135.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V135.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V135.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V135.Data.Message.Id Evergreen.V135.Data.Message.Message
    , items : Dict.Dict Evergreen.V135.Data.Item.Id Evergreen.V135.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V135.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V135.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V135.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V135.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V135.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V135.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V135.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V135.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V135.Data.Auth.Auth Evergreen.V135.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V135.Data.Xp.Xp
    , name : Evergreen.V135.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V135.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V135.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V135.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V135.Data.Message.Id Evergreen.V135.Data.Message.Message
    , items : Dict.Dict Evergreen.V135.Data.Item.Id Evergreen.V135.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V135.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V135.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V135.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V135.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V135.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V135.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V135.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V135.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V135.Data.Xp.Level
    , name : Evergreen.V135.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V135.Data.HealthStatus.HealthStatus
    , location : Evergreen.V135.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V135.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V135.Data.Item.Kind.Kind
            }
    }
