module Evergreen.V114.Frontend.Route exposing (..)

import Evergreen.V114.Data.Message
import Evergreen.V114.Data.Vendor.Shop
import Evergreen.V114.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V114.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V114.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V114.Data.World.Name
    | AdminWorldHiscores Evergreen.V114.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
