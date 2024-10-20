module Evergreen.V108.Data.Vendor exposing (..)

import Dict
import Evergreen.V108.Data.Item
import Evergreen.V108.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V108.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V108.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V108.Data.Item.Id Evergreen.V108.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
