module Evergreen.V13.Frontend.Route exposing (..)

import Evergreen.V13.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V13.Data.Fight.FightInfo