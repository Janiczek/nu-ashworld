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

import AssocList as Dict_
import AssocList.ExtraExtra as Dict_
import AssocSet as Set_
import AssocSet.Extra as Set_
import Data.Auth as Auth
    exposing
        ( Auth
        , HasAuth
        , Password
        , Verified
        )
import Data.HealthStatus as HealthStatus exposing (HealthStatus)
import Data.Item as Item exposing (Item)
import Data.Map as Map exposing (TileNum)
import Data.Map.Location as Location
import Data.Message as Message exposing (Message)
import Data.NewChar as NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Skill as Skill exposing (Skill)
import Data.Special as Special exposing (Special)
import Data.Trait as Trait exposing (Trait)
import Data.Xp as Xp exposing (Level, Xp)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Logic
import Time exposing (Posix)


type Player a
    = NeedsCharCreated (Auth Verified)
    | Player a


type alias SPlayer =
    { name : PlayerName
    , password : Password Verified
    , hp : Int
    , maxHp : Int
    , xp : Int
    , -- doesn't contain bonunses from traits, perks, armor, drugs, etc.
      baseSpecial : Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , perks : Dict_.Dict Perk Int
    , messages : List Message
    , items : Dict Item.Id Item
    , traits : Set_.Set Trait
    , -- doesn't contain Special skill percentages:
      addedSkillPercentages : Dict_.Dict Skill Int
    , taggedSkills : Set_.Set Skill
    , availableSkillPoints : Int
    , availablePerks : Int
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : PlayerName
    , baseSpecial : Special
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , perks : Dict_.Dict Perk Int
    , messages : List Message
    , items : Dict Item.Id Item
    , traits : Set_.Set Trait
    , -- doesn't contain Special skill percentages:
      addedSkillPercentages : Dict_.Dict Skill Int
    , taggedSkills : Set_.Set Skill
    , availableSkillPoints : Int
    , availablePerks : Int
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
        , ( "hp", JE.int player.hp )
        , ( "maxHp", JE.int player.maxHp )
        , ( "xp", JE.int player.xp )
        , ( "baseSpecial", Special.encode player.baseSpecial )
        , ( "caps", JE.int player.caps )
        , ( "ticks", JE.int player.ticks )
        , ( "wins", JE.int player.wins )
        , ( "losses", JE.int player.losses )
        , ( "location", JE.int player.location )
        , ( "perks", Dict_.encode Perk.encode JE.int player.perks )
        , ( "messages", JE.list Message.encode player.messages )
        , ( "items", Dict.encode JE.int Item.encode player.items )
        , ( "traits", Set_.encode Trait.encode player.traits )
        , ( "addedSkillPercentages", Dict_.encode Skill.encode JE.int player.addedSkillPercentages )
        , ( "taggedSkills", Set_.encode Skill.encode player.taggedSkills )
        , ( "availableSkillPoints", JE.int player.availableSkillPoints )
        , ( "availablePerks", JE.int player.availablePerks )
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
    JD.oneOf
        [ sPlayerDecoderV2
        , sPlayerDecoderV1
        ]


{-| with skills we are getting a reset!
-}
sPlayerDecoderV1 : Decoder SPlayer
sPlayerDecoderV1 =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "hp" JD.int)
        |> JD.andMap (JD.field "maxHp" JD.int)
        |> JD.andMap (JD.field "xp" JD.int)
        |> JD.andMap (JD.field "baseSpecial" Special.decoder)
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "ticks" JD.int)
        |> JD.andMap (JD.field "wins" JD.int)
        |> JD.andMap (JD.field "losses" JD.int)
        |> JD.andMap (JD.field "location" JD.int)
        |> JD.andMap (JD.field "perks" (Dict_.decoder Perk.decoder JD.int))
        |> JD.andMap (JD.field "messages" (JD.list Message.decoder))
        |> JD.andMap (JD.field "items" (Dict.decoder JD.int Item.decoder))
        |> JD.andMap (JD.field "traits" (Set_.decoder Trait.decoder))
        |> JD.andMap (JD.field "addedSkillPercentages" (Dict_.decoder Skill.decoder JD.int))
        |> JD.andMap (JD.field "taggedSkills" (Set_.decoder Skill.decoder))
        |> JD.andMap (JD.field "availableSkillPoints" JD.int)
        |> JD.andMap (JD.succeed 0)


{-| adding `availablePerks`
-}
sPlayerDecoderV2 : Decoder SPlayer
sPlayerDecoderV2 =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "hp" JD.int)
        |> JD.andMap (JD.field "maxHp" JD.int)
        |> JD.andMap (JD.field "xp" JD.int)
        |> JD.andMap (JD.field "baseSpecial" Special.decoder)
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "ticks" JD.int)
        |> JD.andMap (JD.field "wins" JD.int)
        |> JD.andMap (JD.field "losses" JD.int)
        |> JD.andMap (JD.field "location" JD.int)
        |> JD.andMap (JD.field "perks" (Dict_.decoder Perk.decoder JD.int))
        |> JD.andMap (JD.field "messages" (JD.list Message.decoder))
        |> JD.andMap (JD.field "items" (Dict.decoder JD.int Item.decoder))
        |> JD.andMap (JD.field "traits" (Set_.decoder Trait.decoder))
        |> JD.andMap (JD.field "addedSkillPercentages" (Dict_.decoder Skill.decoder JD.int))
        |> JD.andMap (JD.field "taggedSkills" (Set_.decoder Skill.decoder))
        |> JD.andMap (JD.field "availableSkillPoints" JD.int)
        |> JD.andMap (JD.field "availablePerks" JD.int)


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , baseSpecial = p.baseSpecial
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
    }


serverToClientOther : { perception : Int } -> SPlayer -> COtherPlayer
serverToClientOther { perception } p =
    { level = Xp.currentLevel p.xp
    , name = p.name
    , wins = p.wins
    , losses = p.losses
    , healthStatus = HealthStatus.check perception p
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
            }


fromNewChar : Posix -> Auth Verified -> NewChar -> Result NewChar.CreationError SPlayer
fromNewChar currentTime auth newChar =
    let
        finalSpecial : Special
        finalSpecial =
            Logic.special
                { baseSpecial = newChar.baseSpecial
                , hasBruiserTrait = Trait.isSelected Trait.Bruiser newChar.traits
                , hasGiftedTrait = Trait.isSelected Trait.Gifted newChar.traits
                , hasSmallFrameTrait = Trait.isSelected Trait.SmallFrame newChar.traits
                , isNewChar = True
                }
    in
    if Set_.size newChar.taggedSkills /= 3 then
        Err NewChar.DoesNotHaveThreeTaggedSkills

    else if newChar.availableSpecial > 0 then
        Err NewChar.HasSpecialPointsLeft

    else if Special.sum newChar.baseSpecial > 40 then
        Err NewChar.UsedMoreSpecialPointsThanAvailable

    else if not <| Special.isInRange finalSpecial then
        Err NewChar.HasSpecialOutOfRange

    else if Set_.size newChar.traits > 2 then
        Err NewChar.HasMoreThanTwoTraits

    else
        Ok <|
            let
                hp : Int
                hp =
                    Logic.hitpoints
                        { level = 1
                        , finalSpecial = finalSpecial
                        }

                startingTileNum : TileNum
                startingTileNum =
                    Location.default
                        |> Location.coords
                        |> Map.toTileNum
            in
            { name = auth.name
            , password = auth.password
            , hp = hp
            , maxHp = hp
            , xp = 0
            , baseSpecial = newChar.baseSpecial
            , caps = 15
            , ticks = 10
            , wins = 0
            , losses = 0
            , location = startingTileNum
            , perks = Dict_.empty
            , messages = [ Message.new currentTime Message.Welcome ]
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
            }
