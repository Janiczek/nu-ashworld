module Evergreen.V88.Frontend.Route exposing (..)

import Evergreen.V88.Data.Barter
import Evergreen.V88.Data.Fight
import Evergreen.V88.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V88.Data.Barter.State
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
    | Fight Evergreen.V88.Data.Fight.Info
    | Messages
    | Message Evergreen.V88.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
