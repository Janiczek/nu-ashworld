module Evergreen.V22.Frontend.Route exposing (..)

import Evergreen.V22.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V22.Data.Fight.FightInfo
    | CharCreation