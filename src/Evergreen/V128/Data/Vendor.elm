module Evergreen.V128.Data.Vendor exposing (..)

import Dict
import Evergreen.V128.Data.Item
import Evergreen.V128.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V128.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V128.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V128.Data.Item.Id Evergreen.V128.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
