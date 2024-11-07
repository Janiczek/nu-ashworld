module Evergreen.V133.Frontend.Route exposing (..)

import Evergreen.V133.Data.Message
import Evergreen.V133.Data.Vendor.Shop
import Evergreen.V133.Data.World
import Url


type PlayerRoute
    = AboutWorld
    | Character
    | Inventory
    | Ladder
    | TownMainSquare
    | TownStore Evergreen.V133.Data.Vendor.Shop.Shop
    | Fight
    | Messages
    | Message Evergreen.V133.Data.Message.Id
    | SettingsFightStrategy


type AdminRoute
    = AdminWorldsList
    | AdminWorldActivity Evergreen.V133.Data.World.Name
    | AdminWorldHiscores Evergreen.V133.Data.World.Name


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
