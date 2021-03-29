module Evergreen.V37.Frontend.Route exposing (..)

import Evergreen.V37.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V37.Data.Fight.FightInfo
    | CharCreation