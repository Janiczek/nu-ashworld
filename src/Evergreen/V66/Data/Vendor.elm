module Evergreen.V66.Data.Vendor exposing (..)

import Dict
import Evergreen.V66.Data.Item


type VendorName
    = KlamathMaidaBuckner


type alias Vendor =
    { name : VendorName
    , items : Dict.Dict Evergreen.V66.Data.Item.Id Evergreen.V66.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
