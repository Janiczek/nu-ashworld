module Evergreen.V129.Data.Player exposing (..)

import Dict
import Evergreen.V129.Data.Auth
import Evergreen.V129.Data.FightStrategy
import Evergreen.V129.Data.HealthStatus
import Evergreen.V129.Data.Item
import Evergreen.V129.Data.Item.Kind
import Evergreen.V129.Data.Map
import Evergreen.V129.Data.Message
import Evergreen.V129.Data.Perk
import Evergreen.V129.Data.Player.PlayerName
import Evergreen.V129.Data.Quest
import Evergreen.V129.Data.Skill
import Evergreen.V129.Data.Special
import Evergreen.V129.Data.Trait
import Evergreen.V129.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V129.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V129.Data.Auth.Password Evergreen.V129.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V129.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V129.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V129.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V129.Data.Message.Id Evergreen.V129.Data.Message.Message
    , items : Dict.Dict Evergreen.V129.Data.Item.Id Evergreen.V129.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V129.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V129.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V129.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V129.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V129.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V129.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V129.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V129.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V129.Data.Auth.Auth Evergreen.V129.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V129.Data.Xp.Xp
    , name : Evergreen.V129.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V129.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V129.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V129.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V129.Data.Message.Id Evergreen.V129.Data.Message.Message
    , items : Dict.Dict Evergreen.V129.Data.Item.Id Evergreen.V129.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V129.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V129.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V129.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V129.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V129.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V129.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V129.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V129.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V129.Data.Xp.Level
    , name : Evergreen.V129.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V129.Data.HealthStatus.HealthStatus
    , location : Evergreen.V129.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V129.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V129.Data.Item.Kind.Kind
            }
    }
