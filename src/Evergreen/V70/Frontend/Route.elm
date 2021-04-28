module Evergreen.V70.Frontend.Route exposing (..)

import Evergreen.V70.Data.Barter
import Evergreen.V70.Data.Fight
import Evergreen.V70.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V70.Data.Barter.State
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
    | Fight Evergreen.V70.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V70.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
