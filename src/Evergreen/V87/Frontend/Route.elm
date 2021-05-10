module Evergreen.V87.Frontend.Route exposing (..)

import Evergreen.V87.Data.Barter
import Evergreen.V87.Data.Fight
import Evergreen.V87.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V87.Data.Barter.State
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
    | Fight Evergreen.V87.Data.Fight.Info
    | Messages
    | Message Evergreen.V87.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
