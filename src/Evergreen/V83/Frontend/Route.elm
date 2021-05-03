module Evergreen.V83.Frontend.Route exposing (..)

import Evergreen.V83.Data.Barter
import Evergreen.V83.Data.Fight
import Evergreen.V83.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V83.Data.Barter.State
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
    | Fight Evergreen.V83.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V83.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
