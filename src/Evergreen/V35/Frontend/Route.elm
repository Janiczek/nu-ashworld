module Evergreen.V35.Frontend.Route exposing (..)

import Evergreen.V35.Data.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V35.Data.Fight.FightInfo
    | CharCreation