module Evergreen.V105.Frontend.Route exposing (..)

import Evergreen.V105.Data.Message
import Evergreen.V105.Data.Vendor.Shop
import Evergreen.V105.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V105.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V105.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V105.Data.World.Name
    | AdminWorldHiscores Evergreen.V105.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
