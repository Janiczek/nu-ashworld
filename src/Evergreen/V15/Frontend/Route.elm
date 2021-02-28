module Evergreen.V15.Frontend.Route exposing (..)

import Evergreen.V15.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V15.Data.Fight.FightInfo