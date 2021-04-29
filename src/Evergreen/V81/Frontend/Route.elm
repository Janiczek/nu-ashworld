module Evergreen.V81.Frontend.Route exposing (..)

import Evergreen.V81.Data.Barter
import Evergreen.V81.Data.Fight
import Evergreen.V81.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V81.Data.Barter.State
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
    | Fight Evergreen.V81.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V81.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
