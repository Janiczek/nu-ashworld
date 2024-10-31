module Evergreen.V114.Data.Vendor exposing (..)

import Dict
import Evergreen.V114.Data.Item
import Evergreen.V114.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V114.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V114.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V114.Data.Item.Id Evergreen.V114.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
