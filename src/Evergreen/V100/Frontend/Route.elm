module Evergreen.V100.Frontend.Route exposing (..)

import Evergreen.V100.Data.Barter
import Evergreen.V100.Data.Fight
import Evergreen.V100.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V100.Data.Barter.State
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
    | Fight Evergreen.V100.Data.Fight.Info
    | Messages
    | Message Evergreen.V100.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
    | Settings
