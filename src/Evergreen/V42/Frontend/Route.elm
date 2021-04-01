module Evergreen.V42.Frontend.Route exposing (..)

import Evergreen.V42.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V42.Data.Fight.FightInfo
    | CharCreation