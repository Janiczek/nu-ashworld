module Evergreen.V119.Data.Player exposing (..)

import Dict
import Evergreen.V119.Data.Auth
import Evergreen.V119.Data.FightStrategy
import Evergreen.V119.Data.HealthStatus
import Evergreen.V119.Data.Item
import Evergreen.V119.Data.Item.Kind
import Evergreen.V119.Data.Map
import Evergreen.V119.Data.Message
import Evergreen.V119.Data.Perk
import Evergreen.V119.Data.Player.PlayerName
import Evergreen.V119.Data.Quest
import Evergreen.V119.Data.Skill
import Evergreen.V119.Data.Special
import Evergreen.V119.Data.Trait
import Evergreen.V119.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V119.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V119.Data.Auth.Password Evergreen.V119.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V119.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V119.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V119.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V119.Data.Message.Id Evergreen.V119.Data.Message.Message
    , items : Dict.Dict Evergreen.V119.Data.Item.Id Evergreen.V119.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V119.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V119.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V119.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V119.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V119.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V119.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V119.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V119.Data.Quest.Name
    , hasCar : Bool
    }


type Player a
    = NeedsCharCreated (Evergreen.V119.Data.Auth.Auth Evergreen.V119.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V119.Data.Xp.Xp
    , name : Evergreen.V119.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V119.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V119.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V119.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V119.Data.Message.Id Evergreen.V119.Data.Message.Message
    , items : Dict.Dict Evergreen.V119.Data.Item.Id Evergreen.V119.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V119.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V119.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V119.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V119.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V119.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V119.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V119.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V119.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V119.Data.Xp.Level
    , name : Evergreen.V119.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V119.Data.HealthStatus.HealthStatus
    }
