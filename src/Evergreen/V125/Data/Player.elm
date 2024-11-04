module Evergreen.V125.Data.Player exposing (..)

import Dict
import Evergreen.V125.Data.Auth
import Evergreen.V125.Data.FightStrategy
import Evergreen.V125.Data.HealthStatus
import Evergreen.V125.Data.Item
import Evergreen.V125.Data.Item.Kind
import Evergreen.V125.Data.Map
import Evergreen.V125.Data.Message
import Evergreen.V125.Data.Perk
import Evergreen.V125.Data.Player.PlayerName
import Evergreen.V125.Data.Quest
import Evergreen.V125.Data.Skill
import Evergreen.V125.Data.Special
import Evergreen.V125.Data.Trait
import Evergreen.V125.Data.Xp
import SeqDict
import SeqSet


type alias SPlayer =
    { name : Evergreen.V125.Data.Player.PlayerName.PlayerName
    , password : Evergreen.V125.Data.Auth.Password Evergreen.V125.Data.Auth.Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Evergreen.V125.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V125.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V125.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V125.Data.Message.Id Evergreen.V125.Data.Message.Message
    , items : Dict.Dict Evergreen.V125.Data.Item.Id Evergreen.V125.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V125.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V125.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V125.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V125.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V125.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V125.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V125.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V125.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type Player a
    = NeedsCharCreated (Evergreen.V125.Data.Auth.Auth Evergreen.V125.Data.Auth.Verified)
    | Player a


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Evergreen.V125.Data.Xp.Xp
    , name : Evergreen.V125.Data.Player.PlayerName.PlayerName
    , special : Evergreen.V125.Data.Special.Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : Evergreen.V125.Data.Map.TileCoords
    , perks : SeqDict.SeqDict Evergreen.V125.Data.Perk.Perk Int
    , messages : Dict.Dict Evergreen.V125.Data.Message.Id Evergreen.V125.Data.Message.Message
    , items : Dict.Dict Evergreen.V125.Data.Item.Id Evergreen.V125.Data.Item.Item
    , traits : SeqSet.SeqSet Evergreen.V125.Data.Trait.Trait
    , addedSkillPercentages : SeqDict.SeqDict Evergreen.V125.Data.Skill.Skill Int
    , taggedSkills : SeqSet.SeqSet Evergreen.V125.Data.Skill.Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Evergreen.V125.Data.Item.Item
    , equippedWeapon : Maybe Evergreen.V125.Data.Item.Item
    , preferredAmmo : Maybe Evergreen.V125.Data.Item.Kind.Kind
    , fightStrategy : Evergreen.V125.Data.FightStrategy.FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet.SeqSet Evergreen.V125.Data.Quest.Name
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Evergreen.V125.Data.Xp.Level
    , name : Evergreen.V125.Data.Player.PlayerName.PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : Evergreen.V125.Data.HealthStatus.HealthStatus
    , location : Evergreen.V125.Data.Map.TileCoords
    , equipment :
        Maybe
            { weapon : Maybe Evergreen.V125.Data.Item.Kind.Kind
            , armor : Maybe Evergreen.V125.Data.Item.Kind.Kind
            }
    }
