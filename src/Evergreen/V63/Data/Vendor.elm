module Evergreen.V63.Data.Vendor exposing (..)

import Dict
import Evergreen.V63.Data.Item


type alias Vendor =
    { items : Dict.Dict Evergreen.V63.Data.Item.Id Evergreen.V63.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }


type alias Vendors =
    { klamath : Vendor
    }
