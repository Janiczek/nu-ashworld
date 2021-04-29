module Evergreen.V78.Frontend.Route exposing (..)

import Evergreen.V78.Data.Barter
import Evergreen.V78.Data.Fight
import Evergreen.V78.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V78.Data.Barter.State
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
    | Fight Evergreen.V78.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V78.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
