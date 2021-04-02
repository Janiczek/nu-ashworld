module Evergreen.V50.Frontend.Route exposing (..)

import Evergreen.V50.Data.Fight


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
    | Fight Evergreen.V50.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute