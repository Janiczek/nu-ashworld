module Evergreen.V96.Frontend.Route exposing (..)

import Evergreen.V96.Data.Barter
import Evergreen.V96.Data.Fight
import Evergreen.V96.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V96.Data.Barter.State
        }


type AdminRoute
    = LoggedIn


type Route
    = Character
    | Inventory
    | Map
    | Ladder
    | Town TownRoute
    | About
    | News
    | Fight Evergreen.V96.Data.Fight.Info
    | Messages
    | Message Evergreen.V96.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
