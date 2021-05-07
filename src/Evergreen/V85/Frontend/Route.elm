module Evergreen.V85.Frontend.Route exposing (..)

import Evergreen.V85.Data.Barter
import Evergreen.V85.Data.Fight
import Evergreen.V85.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V85.Data.Barter.State
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
    | Fight Evergreen.V85.Data.Fight.Info
    | Messages
    | Message Evergreen.V85.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
