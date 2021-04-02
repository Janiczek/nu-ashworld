module Evergreen.V55.Frontend.Route exposing (..)

import Evergreen.V55.Data.Fight


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
    | Fight Evergreen.V55.Data.Fight.FightInfo
    | CharCreation
    | Admin AdminRoute