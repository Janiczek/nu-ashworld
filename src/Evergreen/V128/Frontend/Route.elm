module Evergreen.V128.Frontend.Route exposing (..)

import Evergreen.V128.Data.Message
import Evergreen.V128.Data.Vendor.Shop
import Evergreen.V128.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V128.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V128.Data.Message.Id
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V128.Data.World.Name
    | AdminWorldHiscores Evergreen.V128.Data.World.Name


type Route
    = About
    | Guide (Maybe String)
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | CharCreation
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
