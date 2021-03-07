module Evergreen.V29.Frontend.Route exposing (..)

import Evergreen.V29.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V29.Data.Fight.FightInfo
    | CharCreation