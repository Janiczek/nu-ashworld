module Evergreen.V112.Frontend.Route exposing (..)

import Evergreen.V112.Data.Message
import Evergreen.V112.Data.Vendor.Shop
import Evergreen.V112.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V112.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V112.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V112.Data.World.Name
    | AdminWorldHiscores Evergreen.V112.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
