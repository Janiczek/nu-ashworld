module Evergreen.V125.Frontend.Route exposing (..)

import Evergreen.V125.Data.Message
import Evergreen.V125.Data.Vendor.Shop
import Evergreen.V125.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V125.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V125.Data.Message.Id
    | SettingsFightStrategy
    | SettingsFightStrategySyntaxHelp


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V125.Data.World.Name
    | AdminWorldHiscores Evergreen.V125.Data.World.Name


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
