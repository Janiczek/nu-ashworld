module Evergreen.V75.Frontend.Route exposing (..)

import Evergreen.V75.Data.Barter
import Evergreen.V75.Data.Fight
import Evergreen.V75.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V75.Data.Barter.State
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
    | Fight Evergreen.V75.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V75.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
