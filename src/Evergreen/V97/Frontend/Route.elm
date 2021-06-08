module Evergreen.V97.Frontend.Route exposing (..)

import Evergreen.V97.Data.Barter
import Evergreen.V97.Data.Fight
import Evergreen.V97.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V97.Data.Barter.State
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
    | Fight Evergreen.V97.Data.Fight.Info
    | Messages
    | Message Evergreen.V97.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
