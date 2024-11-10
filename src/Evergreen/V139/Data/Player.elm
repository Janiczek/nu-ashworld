module Evergreen.V139.Data.Player exposing (..)

import Dict
import Evergreen.V139.Data.Auth
import Evergreen.V139.Data.FightStrategy
import Evergreen.V139.Data.HealthStatus
import Evergreen.V139.Data.Item
import Evergreen.V139.Data.Item.Kind
import Evergreen.V139.Data.Map
import Evergreen.V139.Data.Message
import Evergreen.V139.Data.Perk
import Evergreen.V139.Data.Player.PlayerName
import Evergreen.V139.Data.Quest
import Evergreen.V139.Data.Skill
import Evergreen.V139.Data.Special
import Evergreen.V139.Data.Trait
import Evergreen.V139.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V139.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V139.Data.Auth.Password Evergreen.V139.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V139.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V139.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V139.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V139.Data.Message.Id Evergreen.V139.Data.Message.Message
    , items : Dict.Dict Evergreen.V139.Data.Item.Id Evergreen.V139.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V139.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V139.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V139.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V139.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V139.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V139.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V139.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V139.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V139.Data.Auth.Auth Evergreen.V139.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V139.Data.Xp.Xp
    , name : Evergreen.V139.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V139.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V139.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V139.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V139.Data.Message.Id Evergreen.V139.Data.Message.Message
    , items : Dict.Dict Evergreen.V139.Data.Item.Id Evergreen.V139.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V139.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V139.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V139.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V139.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V139.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V139.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V139.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V139.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V139.Data.Xp.Level
    , name : Evergreen.V139.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V139.Data.HealthStatus.HealthStatus
    , location : Evergreen.V139.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V139.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V139.Data.Item.Kind.Kind
            }
    }
