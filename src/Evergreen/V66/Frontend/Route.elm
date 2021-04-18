module Evergreen.V66.Frontend.Route exposing (..)

import Evergreen.V66.Data.Barter
import Evergreen.V66.Data.Fight
import Evergreen.V66.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V66.Data.Barter.State
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
    | Fight Evergreen.V66.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V66.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
