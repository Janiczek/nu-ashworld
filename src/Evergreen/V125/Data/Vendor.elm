module Evergreen.V125.Data.Vendor exposing (..)

import Dict
import Evergreen.V125.Data.Item
import Evergreen.V125.Data.Vendor.Shop


type alias Vendor =
    { shop : Evergreen.V125.Data.Vendor.Shop.Shop
    , currentSpec : Evergreen.V125.Data.Vendor.Shop.ShopSpec
    , items : Dict.Dict Evergreen.V125.Data.Item.Id Evergreen.V125.Data.Item.Item
    , caps : Int
    , discountPct : Int
    }
