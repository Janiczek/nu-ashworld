module Evergreen.V34.Frontend.Route exposing (..)

import Evergreen.V34.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V34.Data.Fight.FightInfo
    | CharCreation