module Evergreen.V61.Data.Vendor exposing (..)

import Dict
import Evergreen.V61.Data.Item


type alias Vendor =
    { items : Dict.Dict Evergreen.V61.Data.Item.Id Evergreen.V61.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }
