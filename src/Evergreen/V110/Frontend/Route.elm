module Evergreen.V110.Frontend.Route exposing (..)

import Evergreen.V110.Data.Message
import Evergreen.V110.Data.Vendor.Shop
import Evergreen.V110.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V110.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V110.Data.Message.Id
    | CharCreation
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V110.Data.World.Name
    | AdminWorldHiscores Evergreen.V110.Data.World.Name


type Route
    = About
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
