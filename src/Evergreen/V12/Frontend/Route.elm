module Evergreen.V12.Frontend.Route exposing (..)

import Evergreen.V12.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V12.Data.Fight.FightInfo