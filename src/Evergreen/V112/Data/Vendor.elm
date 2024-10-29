module Evergreen.V112.Data.Vendor exposing (..)

import Dict
import Evergreen.V112.Data.Item
import Evergreen.V112.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V112.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V112.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V112.Data.Item.Id Evergreen.V112.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
