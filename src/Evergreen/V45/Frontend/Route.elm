module Evergreen.V45.Frontend.Route exposing (..)

import Evergreen.V45.Data.Fight


type AdminRoute
    = Players
    | LoggedIn


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V45.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute