module Evergreen.V10.Frontend.Route exposing (..)

import Evergreen.V10.Types.Fight


type Route
    = Character
    | Map
    | Ladder
    | Town
    | Settings
    | FAQ
    | About
    | News
    | Fight Evergreen.V10.Types.Fight.FightInfo