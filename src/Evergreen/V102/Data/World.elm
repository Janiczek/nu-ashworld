module Evergreen.V102.Data.World exposing (..)

import Evergreen.V102.Data.Auth
import Evergreen.V102.Data.Player
import Evergreen.V102.Data.Player.PlayerName
import Evergreen.V102.Data.Vendor
import SeqDict
import Time


type alias WorldLoggedOutData =
    { players : List Evergreen.V102.Data.Player.COtherPlayer
    }


type alias WorldLoggedInData =
    { player : Evergreen.V102.Data.Player.Player Evergreen.V102.Data.Player.CPlayer
    , otherPlayers : List Evergreen.V102.Data.Player.COtherPlayer
    , playerRank : Int
    , vendors : SeqDict.SeqDict Evergreen.V102.Data.Vendor.Name Evergreen.V102.Data.Vendor.Vendor
    }


type alias AdminData =
    { players : List (Evergreen.V102.Data.Player.Player Evergreen.V102.Data.Player.SPlayer)
    , loggedInPlayers : List Evergreen.V102.Data.Player.PlayerName.PlayerName
    , nextWantedTick : Maybe Time.Posix
    }


type World
    = WorldNotInitialized (Evergreen.V102.Data.Auth.Auth Evergreen.V102.Data.Auth.Plaintext)
    | WorldLoggedOut (Evergreen.V102.Data.Auth.Auth Evergreen.V102.Data.Auth.Plaintext) WorldLoggedOutData
    | WorldLoggedIn WorldLoggedInData
    | WorldAdmin AdminData
