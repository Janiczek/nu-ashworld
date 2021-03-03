module Evergreen.V19.Frontend.Route exposing (..)

import Evergreen.V19.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V19.Data.Fight.FightInfo
    | CharCreation