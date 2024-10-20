module Evergreen.V109.Frontend.Route exposing (..)

import Evergreen.V109.Data.Message
import Evergreen.V109.Data.Vendor.Shop
import Evergreen.V109.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V109.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V109.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V109.Data.World.Name
    | AdminWorldHiscores Evergreen.V109.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
