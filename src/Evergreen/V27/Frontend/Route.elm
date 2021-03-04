module Evergreen.V27.Frontend.Route exposing (..)

import Evergreen.V27.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V27.Data.Fight.FightInfo
    | CharCreation