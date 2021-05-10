module Evergreen.V87.Data.World exposing (..)

import AssocList
import Evergreen.V87.Data.Auth
import Evergreen.V87.Data.Player
import Evergreen.V87.Data.Player.PlayerName
import Evergreen.V87.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V87.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V87.Data.Player.Player Evergreen.V87.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V87.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V87.Data.Vendor.Name Evergreen.V87.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V87.Data.Player.Player Evergreen.V87.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V87.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V87.Data.Auth.Auth Evergreen.V87.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V87.Data.Auth.Auth Evergreen.V87.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
