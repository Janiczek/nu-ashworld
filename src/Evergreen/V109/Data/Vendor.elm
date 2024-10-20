module Evergreen.V109.Data.Vendor exposing (..)

import Dict
import Evergreen.V109.Data.Item
import Evergreen.V109.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V109.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V109.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V109.Data.Item.Id Evergreen.V109.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
