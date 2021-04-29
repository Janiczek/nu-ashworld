module Evergreen.V81.Data.World exposing (..)

import AssocList
import Evergreen.V81.Data.Auth
import Evergreen.V81.Data.Player
import Evergreen.V81.Data.Player.PlayerName
import Evergreen.V81.Data.Vendor
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V81.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V81.Data.Player.Player Evergreen.V81.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V81.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : AssocList.Dict Evergreen.V81.Data.Vendor.Name Evergreen.V81.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V81.Data.Player.Player Evergreen.V81.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V81.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V81.Data.Auth.Auth Evergreen.V81.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V81.Data.Auth.Auth Evergreen.V81.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
