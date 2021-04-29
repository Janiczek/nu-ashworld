module Evergreen.V79.Frontend.Route exposing (..)

import Evergreen.V79.Data.Barter
import Evergreen.V79.Data.Fight
import Evergreen.V79.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V79.Data.Barter.State
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
    | Fight Evergreen.V79.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V79.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
