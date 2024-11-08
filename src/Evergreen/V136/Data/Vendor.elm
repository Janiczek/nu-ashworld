module Evergreen.V136.Data.Vendor exposing (..)

import Dict
import Evergreen.V136.Data.Item
import Evergreen.V136.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V136.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V136.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V136.Data.Item.Id Evergreen.V136.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
