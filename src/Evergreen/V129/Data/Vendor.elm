module Evergreen.V129.Data.Vendor exposing (..)

import Dict
import Evergreen.V129.Data.Item
import Evergreen.V129.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V129.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V129.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V129.Data.Item.Id Evergreen.V129.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
