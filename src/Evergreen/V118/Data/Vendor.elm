module Evergreen.V118.Data.Vendor exposing (..)

import Dict
import Evergreen.V118.Data.Item
import Evergreen.V118.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V118.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V118.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V118.Data.Item.Id Evergreen.V118.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
