module Evergreen.V104.Data.WorldData exposing (..)

import Dict
import Evergreen.V104.Data.Player
import Evergreen.V104.Data.Player.PlayerName
import Evergreen.V104.Data.Tick
import Evergreen.V104.Data.Vendor
import Evergreen.V104.Data.World
import SeqDict
import Time
import Time.Extra


type alias AdminData =
    { worlds :
        Dict.Dict
            Evergreen.V104.Data.World.Name
            { players : Dict.Dict Evergreen.V104.Data.Player.PlayerName.PlayerName (Evergreen.V104.Data.Player.Player Evergreen.V104.Data.Player.SPlayer)
            , nextWantedTick : Maybe Time.Posix
            , description : String
            , startedAt : Time.Posix
            , tickFrequency : Time.Extra.Interval
            , tickPerIntervalCurve : Evergreen.V104.Data.Tick.TickPerIntervalCurve
            , vendorRestockFrequency : Time.Extra.Interval
            }
    , loggedInPlayers : Dict.Dict Evergreen.V104.Data.World.Name (List Evergreen.V104.Data.Player.PlayerName.PlayerName)
    }


type alias PlayerData =
    { worldName : Evergreen.V104.Data.World.Name
    , description : String
    , startedAt : Time.Posix
    , tickFrequency : Time.Extra.Interval
    , tickPerIntervalCurve : Evergreen.V104.Data.Tick.TickPerIntervalCurve
    , vendorRestockFrequency : Time.Extra.Interval
    , player : Evergreen.V104.Data.Player.Player Evergreen.V104.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V104.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V104.Data.Vendor.Name Evergreen.V104.Data.Vendor.Vendor
    }


type WorldData
    = IsAdmin AdminData
    | IsPlayer PlayerData
    | NotLoggedIn
