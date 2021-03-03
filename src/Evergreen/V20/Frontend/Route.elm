module Evergreen.V20.Frontend.Route exposing (..)

import Evergreen.V20.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V20.Data.Fight.FightInfo
    | CharCreation