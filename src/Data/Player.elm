module Data.Player exposing
    ( COtherPlayer
    , CPlayer
    , Player(..)
    , SPlayer
    , clientToClientOther
    , decoder
    , encode
    , encodeSPlayer
    , fromNewChar
    , getAuth
    , getPlayerData
    , map
    , sPlayerDecoder
    , serverToClient
    , serverToClientOther
    )

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
import Data.Map as Map exposing (TileNum)
import Data.Map.Location as Location
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Special.Perception exposing (PerceptionLevel)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp exposing (Level, Xp)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Json.Encode.Extra as JE
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
    , location : TileNum
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
    , equippedAmmo : Maybe Item
    , fightStrategy : FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet Quest.Name
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
    , location : TileNum
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
    , equippedAmmo : Maybe Item
    , fightStrategy : FightStrategy
    , fightStrategyText : String
    , questsActive : SeqSet Quest.Name
    }


type alias COtherPlayer =
    { level : Level
    , name : PlayerName
    , wins : Int
    , losses : Int
    , healthStatus : HealthStatus
    }


encode : (a -> JE.Value) -> Player a -> JE.Value
encode encodeInner player =
    case player of
        NeedsCharCreated auth ->
            JE.object
                [ ( "type", JE.string "needs-char-created" )
                , ( "auth", Auth.encode auth )
                ]

        Player inner ->
            JE.object
                [ ( "type", JE.string "player" )
                , ( "data", encodeInner inner )
                ]


encodeSPlayer : SPlayer -> JE.Value
encodeSPlayer player =
    JE.object
        [ ( "name", JE.string player.name )
        , ( "password", Auth.encodePassword player.password )
        , ( "worldName", JE.string player.worldName )
        , ( "hp", JE.int player.hp )
        , ( "maxHp", JE.int player.maxHp )
        , ( "xp", JE.int player.xp )
        , ( "special", Special.encode player.special )
        , ( "caps", JE.int player.caps )
        , ( "ticks", JE.int player.ticks )
        , ( "wins", JE.int player.wins )
        , ( "losses", JE.int player.losses )
        , ( "location", JE.int player.location )
        , ( "perks", SeqDict.encode Perk.encode JE.int player.perks )
        , ( "messages", JE.list Message.encode (Dict.values player.messages) )
        , ( "items", Dict.encode JE.int Item.encode player.items )
        , ( "traits", SeqSet.encode Trait.encode player.traits )
        , ( "addedSkillPercentages", SeqDict.encode Skill.encode JE.int player.addedSkillPercentages )
        , ( "taggedSkills", SeqSet.encode Skill.encode player.taggedSkills )
        , ( "availableSkillPoints", JE.int player.availableSkillPoints )
        , ( "availablePerks", JE.int player.availablePerks )
        , ( "equippedArmor", JE.maybe Item.encode player.equippedArmor )
        , ( "fightStrategy", FightStrategy.encode player.fightStrategy )
        , ( "fightStrategyText", JE.string player.fightStrategyText )
        , ( "questsActive", SeqSet.encode Quest.encode player.questsActive )
        ]


decoder : Decoder a -> Decoder (Player a)
decoder innerDecoder =
    JD.field "type" JD.string
        |> JD.andThen
            (\type_ ->
                case type_ of
                    "needs-char-created" ->
                        JD.field "auth" Auth.verifiedDecoder
                            |> JD.map NeedsCharCreated

                    "player" ->
                        JD.field "data" innerDecoder
                            |> JD.map Player

                    _ ->
                        JD.fail <| "Unknown player type: '" ++ type_ ++ "'"
            )


sPlayerDecoder : Decoder SPlayer
sPlayerDecoder =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "worldName" JD.string)
        |> JD.andMap (JD.field "hp" JD.parseInt)
        |> JD.andMap (JD.field "maxHp" JD.parseInt)
        |> JD.andMap (JD.field "xp" JD.parseInt)
        |> JD.andMap (JD.field "special" Special.decoder)
        |> JD.andMap (JD.field "caps" JD.parseInt)
        |> JD.andMap (JD.field "ticks" JD.parseInt)
        |> JD.andMap (JD.field "wins" JD.parseInt)
        |> JD.andMap (JD.field "losses" JD.parseInt)
        |> JD.andMap (JD.field "location" JD.parseInt)
        |> JD.andMap (JD.field "perks" (SeqDict.decoder Perk.decoder JD.parseInt))
        |> JD.andMap (JD.field "messages" Message.dictDecoder)
        |> JD.andMap (JD.field "items" (Dict.decoder JD.parseInt Item.decoder))
        |> JD.andMap (JD.field "traits" (SeqSet.decoder Trait.decoder))
        |> JD.andMap (JD.field "addedSkillPercentages" (SeqDict.decoder Skill.decoder JD.parseInt))
        |> JD.andMap (JD.field "taggedSkills" (SeqSet.decoder Skill.decoder))
        |> JD.andMap (JD.field "availableSkillPoints" JD.parseInt)
        |> JD.andMap (JD.field "availablePerks" JD.parseInt)
        |> JD.andMap (JD.field "equippedArmor" (JD.maybe Item.decoder))
        |> JD.andMap (JD.field "equippedWeapon" (JD.maybe Item.decoder))
        |> JD.andMap (JD.field "equippedAmmo" (JD.maybe Item.decoder))
        |> JD.andMap (JD.field "fightStrategy" FightStrategy.decoder)
        |> JD.andMap (JD.field "fightStrategyText" JD.string)
        |> JD.andMap (JD.field "questsActive" (SeqSet.decoder Quest.decoder))


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
    , equippedAmmo = p.equippedAmmo
    , fightStrategy = p.fightStrategy
    , fightStrategyText = p.fightStrategyText
    , questsActive = p.questsActive
    }


serverToClientOther : PerceptionLevel -> SPlayer -> COtherPlayer
serverToClientOther perceptionLevel p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus = HealthStatus.check perceptionLevel p
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

                startingTileNum : TileNum
                startingTileNum =
                    Location.default
                        |> Location.coords
                        |> Map.toTileNum
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
            , location = startingTileNum
            , perks = SeqDict.empty
            , messages =
                [ Message.new 0 currentTime Message.Welcome ]
                    |> List.map (\message -> ( message.id, message ))
                    |> Dict.fromList
            , items = Dict.empty
            , traits = newChar.traits
            , addedSkillPercentages =
                Logic.addedSkillPercentages
                    { taggedSkills = newChar.taggedSkills
                    , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                    }
            , taggedSkills = newChar.taggedSkills
            , availableSkillPoints = 0
            , availablePerks = 0
            , equippedArmor = Nothing
            , equippedWeapon = Nothing
            , equippedAmmo = Nothing
            , fightStrategy = Tuple.second FightStrategy.default
            , fightStrategyText =
                Tuple.second FightStrategy.default
                    |> FightStrategy.toString
            , questsActive = SeqSet.empty
            }
