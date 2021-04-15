module Evergreen.V61.Frontend.Route exposing (..)

import Evergreen.V61.Data.Barter
import Evergreen.V61.Data.Fight
import Evergreen.V61.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V61.Data.Barter.State
        }


type AdminRoute
    = Players
    | LoggedIn
    | Import String


type Route
    = Character
    | Map
    | Ladder
    | Town TownRoute
    | Settings
    | About
    | News
    | Fight Evergreen.V61.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V61.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
