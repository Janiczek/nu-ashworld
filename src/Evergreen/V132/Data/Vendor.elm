module Evergreen.V132.Data.Vendor exposing (..)

import Dict
import Evergreen.V132.Data.Item
import Evergreen.V132.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V132.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V132.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V132.Data.Item.Id Evergreen.V132.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
