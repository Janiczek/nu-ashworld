module Evergreen.V89.Frontend.Route exposing (..)

import Evergreen.V89.Data.Barter
import Evergreen.V89.Data.Fight
import Evergreen.V89.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V89.Data.Barter.State
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
    | Fight Evergreen.V89.Data.Fight.Info
    | Messages
    | Message Evergreen.V89.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
