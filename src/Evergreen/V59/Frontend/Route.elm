module Evergreen.V59.Frontend.Route exposing (..)

import Evergreen.V59.Data.Fight
import Evergreen.V59.Data.Message


type AdminRoute
    = Players
    | LoggedIn
    | Import String


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | About
    | News
    | Fight Evergreen.V59.Data.Fight.FightInfo
    | Messages
    | Message Evergreen.V59.Data.Message.Message
    | CharCreation
    | Admin AdminRoute