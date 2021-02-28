module Evergreen.V16.Frontend.Route exposing (..)

import Evergreen.V16.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V16.Data.Fight.FightInfo