module Evergreen.V51.Frontend.Route exposing (..)

import Evergreen.V51.Data.Fight


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
    | FAQ
    | About
    | News
    | Fight Evergreen.V51.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute