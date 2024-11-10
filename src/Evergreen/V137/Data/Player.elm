module Evergreen.V137.Data.Player exposing (..)

import Dict
import Evergreen.V137.Data.Auth
import Evergreen.V137.Data.FightStrategy
import Evergreen.V137.Data.HealthStatus
import Evergreen.V137.Data.Item
import Evergreen.V137.Data.Item.Kind
import Evergreen.V137.Data.Map
import Evergreen.V137.Data.Message
import Evergreen.V137.Data.Perk
import Evergreen.V137.Data.Player.PlayerName
import Evergreen.V137.Data.Quest
import Evergreen.V137.Data.Skill
import Evergreen.V137.Data.Special
import Evergreen.V137.Data.Trait
import Evergreen.V137.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V137.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V137.Data.Auth.Password Evergreen.V137.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V137.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V137.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V137.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V137.Data.Message.Id Evergreen.V137.Data.Message.Message
    , items : Dict.Dict Evergreen.V137.Data.Item.Id Evergreen.V137.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V137.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V137.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V137.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V137.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V137.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V137.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V137.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V137.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V137.Data.Auth.Auth Evergreen.V137.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V137.Data.Xp.Xp
    , name : Evergreen.V137.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V137.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V137.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V137.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V137.Data.Message.Id Evergreen.V137.Data.Message.Message
    , items : Dict.Dict Evergreen.V137.Data.Item.Id Evergreen.V137.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V137.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V137.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V137.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V137.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V137.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V137.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V137.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V137.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V137.Data.Xp.Level
    , name : Evergreen.V137.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V137.Data.HealthStatus.HealthStatus
    , location : Evergreen.V137.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V137.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V137.Data.Item.Kind.Kind
            }
    }
