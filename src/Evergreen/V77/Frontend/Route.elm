module Evergreen.V77.Frontend.Route exposing (..)

import Evergreen.V77.Data.Barter
import Evergreen.V77.Data.Fight
import Evergreen.V77.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V77.Data.Barter.State
        }


type AdminRoute
    = Players
    | LoggedIn


type Route
    = Character
    | Inventory
    | Map
    | Ladder
    | Town TownRoute
    | About
    | News
    | Fight Evergreen.V77.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V77.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
