module Evergreen.V83.Data.World exposing (..)

import AssocList
import Evergreen.V83.Data.Auth
import Evergreen.V83.Data.Player
import Evergreen.V83.Data.Player.PlayerName
import Evergreen.V83.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V83.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V83.Data.Player.Player Evergreen.V83.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V83.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V83.Data.Vendor.Name Evergreen.V83.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V83.Data.Player.Player Evergreen.V83.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V83.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V83.Data.Auth.Auth Evergreen.V83.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V83.Data.Auth.Auth Evergreen.V83.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
