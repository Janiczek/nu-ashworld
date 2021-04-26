module Evergreen.V68.Frontend.Route exposing (..)

import Evergreen.V68.Data.Barter
import Evergreen.V68.Data.Fight
import Evergreen.V68.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V68.Data.Barter.State
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
    | Fight Evergreen.V68.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V68.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
