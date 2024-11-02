module Evergreen.V120.Data.Vendor exposing (..)

import Dict
import Evergreen.V120.Data.Item
import Evergreen.V120.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V120.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V120.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V120.Data.Item.Id Evergreen.V120.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
