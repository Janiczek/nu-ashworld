module Evergreen.V133.Data.Vendor exposing (..)

import Dict
import Evergreen.V133.Data.Item
import Evergreen.V133.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V133.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V133.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V133.Data.Item.Id Evergreen.V133.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
