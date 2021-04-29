module Evergreen.V79.Data.Vendor exposing (..)

import Dict
import Evergreen.V79.Data.Item


type Name
    = KlamathMaidaBuckner
    | DenFlick


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V79.Data.Item.Id Evergreen.V79.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
