module Evergreen.V135.Data.Vendor exposing (..)

import Dict
import Evergreen.V135.Data.Item
import Evergreen.V135.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V135.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V135.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V135.Data.Item.Id Evergreen.V135.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
