module Evergreen.V133.Data.Player exposing (..)

import Dict
import Evergreen.V133.Data.Auth
import Evergreen.V133.Data.FightStrategy
import Evergreen.V133.Data.HealthStatus
import Evergreen.V133.Data.Item
import Evergreen.V133.Data.Item.Kind
import Evergreen.V133.Data.Map
import Evergreen.V133.Data.Message
import Evergreen.V133.Data.Perk
import Evergreen.V133.Data.Player.PlayerName
import Evergreen.V133.Data.Quest
import Evergreen.V133.Data.Skill
import Evergreen.V133.Data.Special
import Evergreen.V133.Data.Trait
import Evergreen.V133.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V133.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V133.Data.Auth.Password Evergreen.V133.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V133.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V133.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V133.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V133.Data.Message.Id Evergreen.V133.Data.Message.Message
    , items : Dict.Dict Evergreen.V133.Data.Item.Id Evergreen.V133.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V133.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V133.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V133.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V133.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V133.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V133.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V133.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V133.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V133.Data.Auth.Auth Evergreen.V133.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V133.Data.Xp.Xp
    , name : Evergreen.V133.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V133.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V133.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V133.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V133.Data.Message.Id Evergreen.V133.Data.Message.Message
    , items : Dict.Dict Evergreen.V133.Data.Item.Id Evergreen.V133.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V133.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V133.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V133.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V133.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V133.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V133.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V133.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V133.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V133.Data.Xp.Level
    , name : Evergreen.V133.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V133.Data.HealthStatus.HealthStatus
    , location : Evergreen.V133.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V133.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V133.Data.Item.Kind.Kind
            }
    }
