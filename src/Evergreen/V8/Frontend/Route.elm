module Evergreen.V8.Frontend.Route exposing (..)

import Evergreen.V8.Types.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V8.Types.Fight.FightInfo