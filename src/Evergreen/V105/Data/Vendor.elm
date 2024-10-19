module Evergreen.V105.Data.Vendor exposing (..)

import Dict
import Evergreen.V105.Data.Item
import Evergreen.V105.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V105.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V105.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V105.Data.Item.Id Evergreen.V105.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
