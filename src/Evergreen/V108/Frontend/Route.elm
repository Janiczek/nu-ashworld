module Evergreen.V108.Frontend.Route exposing (..)

import Evergreen.V108.Data.Message
import Evergreen.V108.Data.Vendor.Shop
import Evergreen.V108.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V108.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V108.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V108.Data.World.Name
    | AdminWorldHiscores Evergreen.V108.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
