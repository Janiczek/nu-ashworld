module Evergreen.V119.Data.Vendor exposing (..)

import Dict
import Evergreen.V119.Data.Item
import Evergreen.V119.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V119.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V119.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V119.Data.Item.Id Evergreen.V119.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }