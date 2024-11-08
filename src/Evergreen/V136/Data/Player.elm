module Evergreen.V136.Data.Player exposing (..)

import Dict
import Evergreen.V136.Data.Auth
import Evergreen.V136.Data.FightStrategy
import Evergreen.V136.Data.HealthStatus
import Evergreen.V136.Data.Item
import Evergreen.V136.Data.Item.Kind
import Evergreen.V136.Data.Map
import Evergreen.V136.Data.Message
import Evergreen.V136.Data.Perk
import Evergreen.V136.Data.Player.PlayerName
import Evergreen.V136.Data.Quest
import Evergreen.V136.Data.Skill
import Evergreen.V136.Data.Special
import Evergreen.V136.Data.Trait
import Evergreen.V136.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V136.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V136.Data.Auth.Password Evergreen.V136.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V136.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V136.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V136.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V136.Data.Message.Id Evergreen.V136.Data.Message.Message
    , items : Dict.Dict Evergreen.V136.Data.Item.Id Evergreen.V136.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V136.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V136.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V136.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V136.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V136.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V136.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V136.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V136.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V136.Data.Auth.Auth Evergreen.V136.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V136.Data.Xp.Xp
    , name : Evergreen.V136.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V136.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V136.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V136.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V136.Data.Message.Id Evergreen.V136.Data.Message.Message
    , items : Dict.Dict Evergreen.V136.Data.Item.Id Evergreen.V136.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V136.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V136.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V136.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V136.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V136.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V136.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V136.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V136.Data.Quest.Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V136.Data.Xp.Level
    , name : Evergreen.V136.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V136.Data.HealthStatus.HealthStatus
    , location : Evergreen.V136.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V136.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V136.Data.Item.Kind.Kind
            }
    }
