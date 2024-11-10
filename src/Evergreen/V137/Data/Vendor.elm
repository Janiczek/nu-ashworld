module Evergreen.V137.Data.Vendor exposing (..)

import Dict
import Evergreen.V137.Data.Item
import Evergreen.V137.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V137.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V137.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V137.Data.Item.Id Evergreen.V137.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
