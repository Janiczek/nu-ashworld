module Evergreen.V58.Frontend.Route exposing (..)

import Evergreen.V58.Data.Fight


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
    | Fight Evergreen.V58.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute