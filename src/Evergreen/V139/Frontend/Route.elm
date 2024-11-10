module Evergreen.V139.Frontend.Route exposing (..)

import Evergreen.V139.Data.Message
import Evergreen.V139.Data.Vendor.Shop
import Evergreen.V139.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V139.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V139.Data.Message.Id
    | SettingsFightStrategy


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V139.Data.World.Name
    | AdminWorldHiscores Evergreen.V139.Data.World.Name


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
