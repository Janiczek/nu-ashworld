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
    , perkCount
    , sPlayerDecoder
    , serverToClient
    , serverToClientOther
    )

import AssocList as Dict_
import AssocList.ExtraExtra as Dict_
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
import Data.NewChar exposing (NewChar)
import Data.Perk as Perk exposing (Perk)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Special as Special exposing (Special)
import Data.Xp as Xp exposing (Level, Xp)
import Dict exposing (Dict)
import Dict.Json as Dict
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
    , special : Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , perks : Dict_.Dict Perk Int
    , messages : List Message
    , items : Dict Item.Id Item
    }


type alias CPlayer =
    { hp : Int
    , maxHp : Int
    , xp : Xp
    , name : PlayerName
    , special : Special
    , availableSpecial : Int
    , caps : Int
    , ticks : Int
    , wins : Int
    , losses : Int
    , location : TileNum
    , perks : Dict_.Dict Perk Int
    , messages : List Message
    , items : Dict Item.Id Item
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
        , ( "special", Special.encode player.special )
        , ( "availableSpecial", JE.int player.availableSpecial )
        , ( "caps", JE.int player.caps )
        , ( "ticks", JE.int player.ticks )
        , ( "wins", JE.int player.wins )
        , ( "losses", JE.int player.losses )
        , ( "location", JE.int player.location )
        , ( "perks", Dict_.encode Perk.encode JE.int player.perks )
        , ( "messages", JE.list Message.encode player.messages )
        , ( "items", Dict.encode JE.int Item.encode player.items )
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
        [ sPlayerDecoderV3
        , sPlayerDecoderV2
        , sPlayerDecoderV1
        ]


sPlayerDecoderV1 : Decoder SPlayer
sPlayerDecoderV1 =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "hp" JD.int)
        |> JD.andMap (JD.field "maxHp" JD.int)
        |> JD.andMap (JD.field "xp" JD.int)
        |> JD.andMap (JD.field "special" Special.decoder)
        |> JD.andMap (JD.field "availableSpecial" JD.int)
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "ticks" JD.int)
        |> JD.andMap (JD.field "wins" JD.int)
        |> JD.andMap (JD.field "losses" JD.int)
        |> JD.andMap (JD.field "location" JD.int)
        |> JD.andMap (JD.field "perks" (Dict_.decoder Perk.decoder JD.int))
        |> JD.andMap (JD.succeed [])
        |> JD.andMap (JD.succeed Dict.empty)


{-| adds "messages" field
-}
sPlayerDecoderV2 : Decoder SPlayer
sPlayerDecoderV2 =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "hp" JD.int)
        |> JD.andMap (JD.field "maxHp" JD.int)
        |> JD.andMap (JD.field "xp" JD.int)
        |> JD.andMap (JD.field "special" Special.decoder)
        |> JD.andMap (JD.field "availableSpecial" JD.int)
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "ticks" JD.int)
        |> JD.andMap (JD.field "wins" JD.int)
        |> JD.andMap (JD.field "losses" JD.int)
        |> JD.andMap (JD.field "location" JD.int)
        |> JD.andMap (JD.field "perks" (Dict_.decoder Perk.decoder JD.int))
        |> JD.andMap (JD.field "messages" (JD.list Message.decoder))
        |> JD.andMap (JD.succeed Dict.empty)


{-| adds "items" field
-}
sPlayerDecoderV3 : Decoder SPlayer
sPlayerDecoderV3 =
    JD.succeed SPlayer
        |> JD.andMap (JD.field "name" JD.string)
        |> JD.andMap (JD.field "password" Auth.verifiedPasswordDecoder)
        |> JD.andMap (JD.field "hp" JD.int)
        |> JD.andMap (JD.field "maxHp" JD.int)
        |> JD.andMap (JD.field "xp" JD.int)
        |> JD.andMap (JD.field "special" Special.decoder)
        |> JD.andMap (JD.field "availableSpecial" JD.int)
        |> JD.andMap (JD.field "caps" JD.int)
        |> JD.andMap (JD.field "ticks" JD.int)
        |> JD.andMap (JD.field "wins" JD.int)
        |> JD.andMap (JD.field "losses" JD.int)
        |> JD.andMap (JD.field "location" JD.int)
        |> JD.andMap (JD.field "perks" (Dict_.decoder Perk.decoder JD.int))
        |> JD.andMap (JD.field "messages" (JD.list Message.decoder))
        |> JD.andMap (JD.field "items" (Dict.decoder JD.int Item.decoder))


serverToClient : SPlayer -> CPlayer
serverToClient p =
    { hp = p.hp
    , maxHp = p.maxHp
    , xp = p.xp
    , name = p.name
    , special = p.special
    , availableSpecial = p.availableSpecial
    , caps = p.caps
    , ticks = p.ticks
    , wins = p.wins
    , losses = p.losses
    , location = p.location
    , perks = p.perks
    , messages = p.messages
    , items = p.items
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


fromNewChar : Posix -> Auth Verified -> NewChar -> SPlayer
fromNewChar currentTime auth newChar =
    let
        hp : Int
        hp =
            Logic.hitpoints
                { level = 1
                , special = newChar.special
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
    , special = newChar.special
    , availableSpecial = newChar.availableSpecial
    , caps = 15
    , ticks = 10
    , wins = 0
    , losses = 0
    , location = startingTileNum
    , perks = Dict_.empty
    , messages = [ Message.new currentTime Message.Welcome ]
    , items = Dict.empty
    }


perkCount : Perk -> SPlayer -> Int
perkCount perk { perks } =
    Dict_.get perk perks
        |> Maybe.withDefault 0
