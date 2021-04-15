module Evergreen.V62.Data.Vendor exposing (..)

import Dict
import Evergreen.V62.Data.Item


type alias Vendor =
    { items : Dict.Dict Evergreen.V62.Data.Item.Id Evergreen.V62.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }
