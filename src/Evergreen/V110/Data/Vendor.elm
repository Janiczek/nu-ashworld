module Evergreen.V110.Data.Vendor exposing (..)

import Dict
import Evergreen.V110.Data.Item
import Evergreen.V110.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V110.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V110.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V110.Data.Item.Id Evergreen.V110.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
