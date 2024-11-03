module Data.World exposing
    ( Name
    , World
    , codec
    , init
    , isQuestDone
    , isQuestDone_
    )

import Codec exposing (Codec)
import Data.Player as Player exposing (Player, SPlayer)
import Data.Player.PlayerName exposing (PlayerName)
import Data.Quest as Quest
import Data.Tick as Tick exposing (TickPerIntervalCurve)
import Data.Vendor as Vendor exposing (Vendor)
import Data.Vendor.Shop as Shop exposing (Shop)
import Dict exposing (Dict)
import Dict.ExtraExtra as Dict
import List.ExtraExtra as List
import SeqDict exposing (SeqDict)
import SeqDict.Extra as SeqDict
import SeqSet exposing (SeqSet)
import SeqSet.Extra as SeqSet
import Set exposing (Set)
import Time exposing (Posix)
import Time.Extra as Time
import Time.ExtraExtra as Time


type alias Name =
    String


type alias World =
    { players : Dict PlayerName (Player SPlayer)
    , nextWantedTick : Maybe Posix
    , nextVendorRestockTick : Maybe Posix
    , vendors : SeqDict Shop Vendor
    , lastItemId : Int
    , description : String
    , startedAt : Posix
    , tickFrequency : Time.Interval
    , tickPerIntervalCurve : TickPerIntervalCurve
    , vendorRestockFrequency : Time.Interval
    , questsProgress : SeqDict Quest.Name (Dict PlayerName Int)
    , questRewardShops : SeqSet Shop
    , -- Which players have paid the item / caps requirement for a quest?
      -- (They'll be able to pause/unpause their progress on the quest for free)
      questRequirementsPaid : SeqDict Quest.Name (Set PlayerName)
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
    , questRewardShops = SeqSet.empty
    , questRequirementsPaid =
        Quest.all
            |> List.map (\q -> ( q, Set.empty ))
            |> SeqDict.fromList
    }


lastItemId : Dict PlayerName (Player SPlayer) -> SeqDict Shop Vendor -> Int
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


codec : Codec World
codec =
    Codec.object
        (\players nextWantedTick nextVendorRestockTick vendors description startedAt tickFrequency tickPerIntervalCurve vendorRestockFrequency questsProgress questRewardShops questRequirementsPaid ->
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
            , questRewardShops = questRewardShops
            , questRequirementsPaid = questRequirementsPaid
            }
        )
        |> Codec.field "players" .players (Dict.codec Codec.string (Player.codec Player.sPlayerCodec))
        |> Codec.field "nextWantedTick" .nextWantedTick (Codec.nullable Time.posixCodec)
        |> Codec.field "nextVendorRestockTick" .nextVendorRestockTick (Codec.nullable Time.posixCodec)
        |> Codec.field "vendors" .vendors (SeqDict.codec Shop.codec Vendor.codec)
        |> Codec.field "description" .description Codec.string
        |> Codec.field "startedAt" .startedAt Time.posixCodec
        |> Codec.field "tickFrequency" .tickFrequency Time.intervalCodec
        |> Codec.field "tickPerIntervalCurve" .tickPerIntervalCurve Tick.curveCodec
        |> Codec.field "vendorRestockFrequency" .vendorRestockFrequency Time.intervalCodec
        |> Codec.field "questsProgress" .questsProgress (SeqDict.codec Quest.codec (Dict.codec Codec.string Codec.int))
        |> Codec.field "questRewardShops" .questRewardShops (SeqSet.codec Shop.codec)
        |> Codec.field
            "questRequirementsPaid"
            .questRequirementsPaid
            (SeqDict.codec Quest.codec (Codec.set Codec.string))
        |> Codec.buildObject


isQuestDone : World -> Quest.Name -> Bool
isQuestDone world quest =
    world.questsProgress
        |> SeqDict.get quest
        |> Maybe.withDefault Dict.empty
        |> (\perPlayer -> isQuestDone_ perPlayer quest)


isQuestDone_ : Dict PlayerName Int -> Quest.Name -> Bool
isQuestDone_ perPlayer quest =
    Dict.values perPlayer
        |> List.sum
        |> (\sum -> sum >= Quest.ticksNeeded quest)
