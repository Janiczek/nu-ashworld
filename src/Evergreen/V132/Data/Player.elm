module Evergreen.V132.Data.Player exposing (..)

import Dict
import Evergreen.V132.Data.Auth
import Evergreen.V132.Data.FightStrategy
import Evergreen.V132.Data.HealthStatus
import Evergreen.V132.Data.Item
import Evergreen.V132.Data.Item.Kind
import Evergreen.V132.Data.Map
import Evergreen.V132.Data.Message
import Evergreen.V132.Data.Perk
import Evergreen.V132.Data.Player.PlayerName
import Evergreen.V132.Data.Quest
import Evergreen.V132.Data.Skill
import Evergreen.V132.Data.Special
import Evergreen.V132.Data.Trait
import Evergreen.V132.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V132.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V132.Data.Auth.Password Evergreen.V132.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V132.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V132.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V132.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V132.Data.Message.Id Evergreen.V132.Data.Message.Message
    , items : Dict.Dict Evergreen.V132.Data.Item.Id Evergreen.V132.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V132.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V132.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V132.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V132.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V132.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V132.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V132.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V132.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V132.Data.Auth.Auth Evergreen.V132.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V132.Data.Xp.Xp
    , name : Evergreen.V132.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V132.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V132.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V132.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V132.Data.Message.Id Evergreen.V132.Data.Message.Message
    , items : Dict.Dict Evergreen.V132.Data.Item.Id Evergreen.V132.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V132.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V132.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V132.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V132.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V132.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V132.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V132.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V132.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V132.Data.Xp.Level
    , name : Evergreen.V132.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V132.Data.HealthStatus.HealthStatus
    , location : Evergreen.V132.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V132.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V132.Data.Item.Kind.Kind
            }
    }
