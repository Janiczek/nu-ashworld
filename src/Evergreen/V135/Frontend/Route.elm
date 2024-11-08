module Evergreen.V135.Frontend.Route exposing (..)

import Evergreen.V135.Data.Message
import Evergreen.V135.Data.Vendor.Shop
import Evergreen.V135.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V135.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V135.Data.Message.Id
    | SettingsFightStrategy


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V135.Data.World.Name
    | AdminWorldHiscores Evergreen.V135.Data.World.Name


type Route
    = About
    | Guide (Maybe String)
    | News
    | Map
    | WorldsList
    | NotFound Url.Url
    | CharCreation
    | FightStrategySyntaxHelp
    | PlayerRoute PlayerRoute
    | AdminRoute AdminRoute
