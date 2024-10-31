module Evergreen.V118.Frontend.Route exposing (..)

import Evergreen.V118.Data.Message
import Evergreen.V118.Data.Vendor.Shop
import Evergreen.V118.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V118.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V118.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V118.Data.World.Name
    | AdminWorldHiscores Evergreen.V118.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
