module Evergreen.V101.Frontend.Route exposing (..)

import Evergreen.V101.Data.Barter
import Evergreen.V101.Data.Fight
import Evergreen.V101.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V101.Data.Barter.State
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
    | Fight Evergreen.V101.Data.Fight.Info
    | Messages
    | Message Evergreen.V101.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
    | Settings
