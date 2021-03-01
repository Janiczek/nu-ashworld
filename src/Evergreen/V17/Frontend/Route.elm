module Evergreen.V17.Frontend.Route exposing (..)

import Evergreen.V17.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V17.Data.Fight.FightInfo
    | CharCreation