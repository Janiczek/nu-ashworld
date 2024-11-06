module Data.Player exposing
    ( COtherPlayer
    , CPlayer
    , Player(..)
    , SPlayer
    , clientToClientOther
    , codec
    , fromNewChar
    , getAuth
    , getPlayerData
    , map
    , sPlayerCodec
    , serverToClient
    , serverToClientOther
    )

import Codec exposing (Codec)
import Data.Auth as Auth
    exposing
        ( Auth
        , HasAuth
        , Password
        , Verified
        )
import Data.FightStrategy as FightStrategy exposing (FightStrategy)
import Data.FightStrategy.Named as FightStrategy
import Data.HealthStatus as HealthStatus exposing (HealthStatus)
import Data.Item as Item exposing (Item)
import Data.Item.Kind as ItemKind
import Data.Map as Map exposing (TileCoords)
import Data.Map.Location as Location
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest exposing (Quest)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Special.Perception exposing (PerceptionLevel)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp exposing (Level, Xp)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Logic
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import SeqSet exposing (SeqSet)
import SeqSet.Extra as SeqSet
import Time exposing (Posix)


type Player a
    = NeedsCharCreated (Auth Verified)
    | Player a


type alias SPlayer =
    { name : PlayerName
    , password : Password Verified
    , worldName : String
    , hp : Int
    , maxHp : Int
    , xp : Int
    , special : Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileCoords
    , perks : SeqDict Perk Int
    , messages : Dict Message.Id Message
    , items : Dict Item.Id Item
    , traits : SeqSet Trait
    , -- doesn't contain Special base skill % values:
      addedSkillPercentages : SeqDict Skill Int
    , taggedSkills : SeqSet Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Item
    , equippedWeapon : Maybe Item
    , preferredAmmo : Maybe ItemKind.Kind
    , fightStrategy : FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet Quest
    , carBatteryPromile : Maybe Int
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : PlayerName
    , special : Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileCoords
    , perks : SeqDict Perk Int
    , messages : Dict Message.Id Message
    , items : Dict Item.Id Item
    , traits : SeqSet Trait
    , -- doesn't contain Special base skill % values:
      addedSkillPercentages : SeqDict Skill Int
    , taggedSkills : SeqSet Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    , equippedArmor : Maybe Item
    , equippedWeapon : Maybe Item
    , preferredAmmo : Maybe ItemKind.Kind
    , fightStrategy : FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet Quest
    , carBatteryPromile : Maybe Int
    }


type alias COtherPlayer =
    { level : Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : HealthStatus
    , location : TileCoords
    , equipment :
        -- Maybe because the info might not be available due to player not having the Awareness perk
        Maybe
            -- Maybes because the player might not have the item equipped
            { weapon : Maybe ItemKind.Kind
            , armor : Maybe ItemKind.Kind
            }
    }


codec : Codec a -> Codec (Player a)
codec other =
    Codec.custom
        (\needsCharCreatedEncoder playerEncoder value ->
            case value of
                NeedsCharCreated auth ->
                    needsCharCreatedEncoder auth

                Player data ->
                    playerEncoder data
        )
        |> Codec.variant1 "NeedsCharCreated" NeedsCharCreated Auth.codec
        |> Codec.variant1 "Player" Player other
        |> Codec.buildCustom


sPlayerCodec : Codec SPlayer
sPlayerCodec =
    Codec.object SPlayer
        |> Codec.field "name" .name Codec.string
        |> Codec.field "password" .password Auth.passwordCodec
        |> Codec.field "worldName" .worldName Codec.string
        |> Codec.field "hp" .hp Codec.int
        |> Codec.field "maxHp" .maxHp Codec.int
        |> Codec.field "xp" .xp Codec.int
        |> Codec.field "special" .special Special.codec
        |> Codec.field "caps" .caps Codec.int
        |> Codec.field "ticks" .ticks Codec.int
        |> Codec.field "wins" .wins Codec.int
        |> Codec.field "losses" .losses Codec.int
        |> Codec.field "location" .location Map.tileCoordsCodec
        |> Codec.field "perks" .perks (SeqDict.codec Data.Perk.codec Codec.int)
        |> Codec.field "messages" .messages (Dict.codec Codec.int Message.codec)
        |> Codec.field "items" .items (Dict.codec Codec.int Item.codec)
        |> Codec.field "traits" .traits (SeqSet.codec Trait.codec)
        |> Codec.field "addedSkillPercentages" .addedSkillPercentages (SeqDict.codec Skill.codec Codec.int)
        |> Codec.field "taggedSkills" .taggedSkills (SeqSet.codec Skill.codec)
        |> Codec.field "availableSkillPoints" .availableSkillPoints Codec.int
        |> Codec.field "availablePerks" .availablePerks Codec.int
        |> Codec.field "equippedArmor" .equippedArmor (Codec.nullable Item.codec)
        |> Codec.field "equippedWeapon" .equippedWeapon (Codec.nullable Item.codec)
        |> Codec.field "preferredAmmo" .preferredAmmo (Codec.nullable ItemKind.codec)
        |> Codec.field "fightStrategy" .fightStrategy FightStrategy.codec
        |> Codec.field "fightStrategyText" .fightStrategyText Codec.string
        |> Codec.field "questsActive" .questsActive (SeqSet.codec Quest.codec)
        |> Codec.field "carBatteryPromile" .carBatteryPromile (Codec.nullable Codec.int)
        |> Codec.buildObject


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , special = p.special
    , caps = p.caps
    , ticks = p.ticks
    , wins = p.wins
    , losses = p.losses
    , location = p.location
    , perks = p.perks
    , messages = p.messages
    , items = p.items
    , traits = p.traits
    , addedSkillPercentages = p.addedSkillPercentages
    , taggedSkills = p.taggedSkills
    , availableSkillPoints = p.availableSkillPoints
    , availablePerks = p.availablePerks
    , equippedArmor = p.equippedArmor
    , equippedWeapon = p.equippedWeapon
    , preferredAmmo = p.preferredAmmo
    , fightStrategy = p.fightStrategy
    , fightStrategyText = p.fightStrategyText
    , questsActive = p.questsActive
    , carBatteryPromile = p.carBatteryPromile
    }


serverToClientOther : { perceptionLevel : PerceptionLevel, hasAwarenessPerk : Bool } -> SPlayer -> COtherPlayer
serverToClientOther { perceptionLevel, hasAwarenessPerk } p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus = HealthStatus.check perceptionLevel p
    , location = p.location
    , equipment =
        if hasAwarenessPerk then
            Just
                { weapon = p.equippedWeapon |> Maybe.map .kind
                , armor = p.equippedArmor |> Maybe.map .kind
                }

        else
            Nothing
    }


clientToClientOther : CPlayer -> COtherPlayer
clientToClientOther p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus =
        HealthStatus.ExactHp
            { current = p.hp
            , max = p.maxHp
            }
    , location = p.location
    , equipment =
        Just
            { weapon = p.equippedWeapon |> Maybe.map .kind
            , armor = p.equippedArmor |> Maybe.map .kind
            }
    }


map : (a -> b) -> Player a -> Player b
map fn player =
    case player of
        NeedsCharCreated auth ->
            NeedsCharCreated auth

        Player a ->
            Player <| fn a


getPlayerData : Player a -> Maybe a
getPlayerData player =
    case player of
        NeedsCharCreated _ ->
            Nothing

        Player data ->
            Just data


getAuth : Player (HasAuth a) -> Auth Verified
getAuth player =
    case player of
        NeedsCharCreated auth ->
            auth

        Player data ->
            { name = data.name
            , password = data.password
            , worldName = data.worldName
            }


fromNewChar : Posix -> Auth Verified -> NewChar -> Result NewChar.CreationError SPlayer
fromNewChar currentTime auth newChar =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.newCharSpecial
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                }
    in
    if SeqSet.size newChar.taggedSkills /= 3 then
        Err NewChar.DoesNotHaveThreeTaggedSkills

    else if newChar.availableSpecial > 0 then
        Err NewChar.HasSpecialPointsLeft

    else if Special.sum newChar.baseSpecial > 40 then
        Err NewChar.UsedMoreSpecialPointsThanAvailable

    else if not <| Special.isInRange finalSpecial then
        Err NewChar.HasSpecialOutOfRange

    else if SeqSet.size newChar.traits > 2 then
        Err NewChar.HasMoreThanTwoTraits

    else
        Ok <|
            let
                hp : Int
                hp =
                    Logic.hitpoints
                        { level = 1
                        , special = finalSpecial
                        , lifegiverPerkRanks = 0
                        }

                startingTileCoords : TileCoords
                startingTileCoords =
                    Location.default
                        |> Location.coords
            in
            { name = auth.name
            , password = auth.password
            , worldName = auth.worldName
            , hp = hp
            , maxHp = hp
            , xp = 0
            , special = finalSpecial
            , caps = 150
            , ticks = 50
            , wins = 0
            , losses = 0
            , location = startingTileCoords
            , perks = SeqDict.empty
            , messages =
                [ Message.new 0 currentTime Message.Welcome ]
                    |> List.map (\message -> ( message.id, message ))
                    |> Dict.fromList
            , items =
                --Dict.fromList
                --    [ ( 1, Item.create { lastId = 0, uniqueKey = { kind = ItemKind.Jhp10mm }, count = 5 } |> Tuple.first )
                --    , ( 2, Item.create { lastId = 1, uniqueKey = { kind = ItemKind.Ap10mm }, count = 5 } |> Tuple.first )
                --    , ( 3, Item.create { lastId = 2, uniqueKey = { kind = ItemKind.Fmj223 }, count = 5 } |> Tuple.first )
                --    , ( 4, Item.create { lastId = 3, uniqueKey = { kind = ItemKind.Smg10mm }, count = 5 } |> Tuple.first )
                --    , ( 5, Item.create { lastId = 4, uniqueKey = { kind = ItemKind.MicrofusionCell }, count = 10 } |> Tuple.first )
                --    ]
                Dict.empty
            , traits = newChar.traits
            , addedSkillPercentages =
                Logic.addedSkillPercentages
                    { taggedSkills = newChar.taggedSkills
                    , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                    }
            , taggedSkills = newChar.taggedSkills
            , availableSkillPoints = 20 -- the Welcome message tells players to try using these, so this shouldn't be 0
            , availablePerks = 0
            , equippedArmor = Nothing
            , equippedWeapon = Nothing
            , preferredAmmo = Nothing
            , fightStrategy = Tuple.second FightStrategy.default
            , fightStrategyText =
                Tuple.second FightStrategy.default
                    |> FightStrategy.toString
            , questsActive = SeqSet.empty
            , carBatteryPromile = Nothing
            }
