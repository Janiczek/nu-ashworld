module Evergreen.V139.Data.Vendor exposing (..)

import Dict
import Evergreen.V139.Data.Item
import Evergreen.V139.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V139.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V139.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V139.Data.Item.Id Evergreen.V139.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
