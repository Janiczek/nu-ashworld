module Data.World exposing
    ( Name
    , World
    , decoder
    , encode
    , init
    )

import Data.Player as Player
    exposing
        ( Player
        , SPlayer
        )
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Tick as Tick exposing (TickPerIntervalCurve(..))
import Data.Vendor as Vendor exposing (Vendor)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import Iso8601
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Extra as JD
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.ExtraExtra as List
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import Time exposing (Posix)
import Time.Extra as Time
import Time.ExtraExtra as Time


type alias Name =
    String


type alias World =
    { players : Dict PlayerName (Player SPlayer)
    , nextWantedTick : Maybe Posix
    , nextVendorRestockTick : Maybe Posix
    , vendors : SeqDict Vendor.Name Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Posix
    , tickFrequency : Time.Interval
    , tickPerIntervalCurve : TickPerIntervalCurve
    , vendorRestockFrequency : Time.Interval
    , questsProgress : SeqDict Quest.Name (Dict PlayerName Int)

    -- TODO perhaps have the shops here too, for some manual admin addition of items?
    -- TODO perhaps have the global rewards here too, for manual addition?
    }


init : { fast : Bool } -> World
init { fast } =
    let
        ( tickFrequency, tickPerIntervalCurve, vendorRestockFrequency ) =
            if fast then
                ( Time.Second
                , Tick.QuarterAndRest { quarter = 2, rest = 1 }
                , Time.Minute
                )

            else
                ( Time.Hour
                , Tick.QuarterAndRest { quarter = 4, rest = 2 }
                , Time.Hour
                )
    in
    { players = Dict.empty
    , nextWantedTick = Nothing
    , nextVendorRestockTick = Nothing
    , vendors = Vendor.emptyVendors
    , lastItemId = 0
    , description = ""
    , startedAt = Time.millisToPosix 0
    , tickFrequency = tickFrequency
    , tickPerIntervalCurve = tickPerIntervalCurve
    , vendorRestockFrequency = vendorRestockFrequency
    , questsProgress =
        Quest.all
            |> List.map (\q -> ( q, Dict.empty ))
            |> SeqDict.fromList
    }


encode : World -> JE.Value
encode world =
    JE.object
        [ ( "players"
          , world.players
                |> Dict.values
                |> JE.list (Player.encode Player.encodeSPlayer)
          )
        , ( "nextWantedTick", JEE.maybe Iso8601.encode world.nextWantedTick )
        , ( "nextVendorRestockTick", JEE.maybe Iso8601.encode world.nextVendorRestockTick )
        , ( "vendors", Vendor.encodeVendors world.vendors )
        , ( "description", JE.string world.description )
        , ( "startedAt", Iso8601.encode world.startedAt )
        , ( "tickFrequency", Time.encodeInterval world.tickFrequency )
        , ( "tickPerIntervalCurve", Tick.encodeCurve world.tickPerIntervalCurve )
        , ( "vendorRestockFrequency", Time.encodeInterval world.vendorRestockFrequency )
        ]


lastItemId : Dict PlayerName (Player SPlayer) -> SeqDict Vendor.Name Vendor -> Int
lastItemId players vendors =
    let
        lastPlayersItemId : Int
        lastPlayersItemId =
            players
                |> Dict.values
                |> List.filterMap Player.getPlayerData
                |> List.fastConcatMap (.items >> Dict.keys)
                |> List.maximum
                |> Maybe.withDefault 0

        lastVendorsItemId : Int
        lastVendorsItemId =
            vendors
                |> SeqDict.values
                |> List.fastConcatMap (.items >> Dict.keys)
                |> List.maximum
                |> Maybe.withDefault 0
    in
    max lastPlayersItemId lastVendorsItemId


decoder : Decoder World
decoder =
    JD.oneOf
        [ decoderV1
        ]


decoderV1 : Decoder World
decoderV1 =
    JD.succeed
        (\players nextWantedTick nextVendorRestockTick vendors description startedAt tickFrequency tickPerIntervalCurve vendorRestockFrequency questsProgress ->
            { players = players
            , nextWantedTick = nextWantedTick
            , nextVendorRestockTick = nextVendorRestockTick
            , vendors = vendors
            , lastItemId = lastItemId players vendors
            , description = description
            , startedAt = startedAt
            , tickFrequency = tickFrequency
            , tickPerIntervalCurve = tickPerIntervalCurve
            , vendorRestockFrequency = vendorRestockFrequency
            , questsProgress = questsProgress
            }
        )
        |> JD.andMap
            (JD.field "players"
                (JD.list
                    (Player.decoder Player.sPlayerDecoder
                        |> JD.map (\player -> ( Player.getAuth player |> .name, player ))
                    )
                    |> JD.map Dict.fromList
                )
            )
        |> JD.andMap (JD.field "nextWantedTick" (JD.maybe Iso8601.decoder))
        |> JD.andMap (JD.field "nextVendorRestockTick" (JD.maybe Iso8601.decoder))
        |> JD.andMap (JD.field "vendors" Vendor.vendorsDecoder)
        |> JD.andMap (JD.field "description" JD.string)
        |> JD.andMap (JD.field "startedAt" Iso8601.decoder)
        |> JD.andMap (JD.field "tickFrequency" Time.intervalDecoder)
        |> JD.andMap (JD.field "tickPerIntervalCurve" Tick.curveDecoder)
        |> JD.andMap (JD.field "vendorRestockFrequency" Time.intervalDecoder)
        |> JD.andMap (JD.field "questsProgress" (SeqDict.decoder Quest.decoder (Dict.decoder JD.string JD.int)))
