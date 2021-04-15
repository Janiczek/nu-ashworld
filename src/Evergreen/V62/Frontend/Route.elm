module Evergreen.V62.Frontend.Route exposing (..)

import Evergreen.V62.Data.Barter
import Evergreen.V62.Data.Fight
import Evergreen.V62.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V62.Data.Barter.State
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
    | Fight Evergreen.V62.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V62.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
