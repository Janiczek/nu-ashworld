module Evergreen.V110.Data.Player exposing (..)

import Dict
import Evergreen.V110.Data.Auth
import Evergreen.V110.Data.FightStrategy
import Evergreen.V110.Data.HealthStatus
import Evergreen.V110.Data.Item
import Evergreen.V110.Data.Item.Kind
import Evergreen.V110.Data.Map
import Evergreen.V110.Data.Message
import Evergreen.V110.Data.Perk
import Evergreen.V110.Data.Player.PlayerName
import Evergreen.V110.Data.Quest
import Evergreen.V110.Data.Skill
import Evergreen.V110.Data.Special
import Evergreen.V110.Data.Trait
import Evergreen.V110.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V110.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V110.Data.Auth.Password Evergreen.V110.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V110.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V110.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V110.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V110.Data.Message.Id Evergreen.V110.Data.Message.Message
    , items : Dict.Dict Evergreen.V110.Data.Item.Id Evergreen.V110.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V110.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V110.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V110.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V110.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V110.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V110.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V110.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V110.Data.Quest.Name
    }


type Player a
    = NeedsCharCreated (Evergreen.V110.Data.Auth.Auth Evergreen.V110.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V110.Data.Xp.Xp
    , name : Evergreen.V110.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V110.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V110.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V110.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V110.Data.Message.Id Evergreen.V110.Data.Message.Message
    , items : Dict.Dict Evergreen.V110.Data.Item.Id Evergreen.V110.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V110.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V110.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V110.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V110.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V110.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V110.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V110.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V110.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V110.Data.Xp.Level
    , name : Evergreen.V110.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V110.Data.HealthStatus.HealthStatus
    }
