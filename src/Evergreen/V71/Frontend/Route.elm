module Evergreen.V71.Frontend.Route exposing (..)

import Evergreen.V71.Data.Barter
import Evergreen.V71.Data.Fight
import Evergreen.V71.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V71.Data.Barter.State
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
    | Fight Evergreen.V71.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V71.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
