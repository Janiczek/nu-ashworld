module Evergreen.V124.Data.Vendor exposing (..)

import Dict
import Evergreen.V124.Data.Item
import Evergreen.V124.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V124.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V124.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V124.Data.Item.Id Evergreen.V124.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
