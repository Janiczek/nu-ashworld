module Evergreen.V69.Data.Vendor exposing (..)

import Dict
import Evergreen.V69.Data.Item


type Name
    = KlamathMaidaBuckner


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V69.Data.Item.Id Evergreen.V69.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
