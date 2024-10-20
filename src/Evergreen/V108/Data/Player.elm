module Evergreen.V108.Data.Player exposing (..)

import Dict
import Evergreen.V108.Data.Auth
import Evergreen.V108.Data.FightStrategy
import Evergreen.V108.Data.HealthStatus
import Evergreen.V108.Data.Item
import Evergreen.V108.Data.Item.Kind
import Evergreen.V108.Data.Map
import Evergreen.V108.Data.Message
import Evergreen.V108.Data.Perk
import Evergreen.V108.Data.Player.PlayerName
import Evergreen.V108.Data.Quest
import Evergreen.V108.Data.Skill
import Evergreen.V108.Data.Special
import Evergreen.V108.Data.Trait
import Evergreen.V108.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V108.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V108.Data.Auth.Password Evergreen.V108.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V108.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V108.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V108.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V108.Data.Message.Id Evergreen.V108.Data.Message.Message
    , items : Dict.Dict Evergreen.V108.Data.Item.Id Evergreen.V108.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V108.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V108.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V108.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V108.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V108.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V108.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V108.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V108.Data.Quest.Name
    }


type Player a
    = NeedsCharCreated (Evergreen.V108.Data.Auth.Auth Evergreen.V108.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V108.Data.Xp.Xp
    , name : Evergreen.V108.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V108.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V108.Data.Map.TileNum
    , perks : SeqDict.SeqDict Evergreen.V108.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V108.Data.Message.Id Evergreen.V108.Data.Message.Message
    , items : Dict.Dict Evergreen.V108.Data.Item.Id Evergreen.V108.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V108.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V108.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V108.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V108.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V108.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V108.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V108.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V108.Data.Quest.Name
    }


type alias COtherPlayer =
    { level : Evergreen.V108.Data.Xp.Level
    , name : Evergreen.V108.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V108.Data.HealthStatus.HealthStatus
    }
