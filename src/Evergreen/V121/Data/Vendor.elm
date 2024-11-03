module Evergreen.V121.Data.Vendor exposing (..)

import Dict
import Evergreen.V121.Data.Item
import Evergreen.V121.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V121.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V121.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V121.Data.Item.Id Evergreen.V121.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
