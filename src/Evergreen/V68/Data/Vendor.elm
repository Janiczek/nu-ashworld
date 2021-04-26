module Evergreen.V68.Data.Vendor exposing (..)

import Dict
import Evergreen.V68.Data.Item


type Name
    = KlamathMaidaBuckner


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V68.Data.Item.Id Evergreen.V68.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
