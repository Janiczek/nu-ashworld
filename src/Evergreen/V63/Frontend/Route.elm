module Evergreen.V63.Frontend.Route exposing (..)

import Evergreen.V63.Data.Barter
import Evergreen.V63.Data.Fight
import Evergreen.V63.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V63.Data.Barter.State
        }


type AdminRoute
    = Players
    | LoggedIn


type Route
    = Character
    | Map
    | Ladder
    | Town TownRoute
    | Settings
    | About
    | News
    | Fight Evergreen.V63.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V63.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
