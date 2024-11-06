module Evergreen.V129.Frontend.Route exposing (..)

import Evergreen.V129.Data.Message
import Evergreen.V129.Data.Vendor.Shop
import Evergreen.V129.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V129.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V129.Data.Message.Id
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V129.Data.World.Name
    | AdminWorldHiscores Evergreen.V129.Data.World.Name


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
