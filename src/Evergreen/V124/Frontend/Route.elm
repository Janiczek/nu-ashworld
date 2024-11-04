module Evergreen.V124.Frontend.Route exposing (..)

import Evergreen.V124.Data.Message
import Evergreen.V124.Data.Vendor.Shop
import Evergreen.V124.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V124.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V124.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V124.Data.World.Name
    | AdminWorldHiscores Evergreen.V124.Data.World.Name


type Route
    = About
    | Guide (Maybe String)
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
