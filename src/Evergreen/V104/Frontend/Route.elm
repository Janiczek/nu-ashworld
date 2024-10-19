module Evergreen.V104.Frontend.Route exposing (..)

import Evergreen.V104.Data.Message
import Evergreen.V104.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore
    | Fight
    | Messages
    | Message Evergreen.V104.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V104.Data.World.Name
    | AdminWorldHiscores Evergreen.V104.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
