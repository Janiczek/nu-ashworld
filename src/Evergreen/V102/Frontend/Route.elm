module Evergreen.V102.Frontend.Route exposing (..)

import Evergreen.V102.Data.Barter
import Evergreen.V102.Data.Fight
import Evergreen.V102.Data.Message


type TownRoute
    = MainSquare
    | Store
        { barter : Evergreen.V102.Data.Barter.State
        }


type AdminRoute
    = LoggedIn


type SettingsRoute
    = FightStrategy
    | FightStrategySyntaxHelp


type alias SettingsData =
    { fightStrategyText : String
    , subroute : SettingsRoute
    }


type Route
    = Character
    | Inventory
    | Map
    | Ladder
    | Town TownRoute
    | About
    | News
    | Fight Evergreen.V102.Data.Fight.Info
    | Messages
    | Message Evergreen.V102.Data.Message.Message
    | CharCreation
    | Admin AdminRoute
    | Settings SettingsData
