module Evergreen.V69.Frontend.Route exposing (..)

import Evergreen.V69.Data.Barter
import Evergreen.V69.Data.Fight
import Evergreen.V69.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V69.Data.Barter.State
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
    | Fight Evergreen.V69.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V69.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
