module Evergreen.V77.Data.Vendor exposing (..)

import Dict
import Evergreen.V77.Data.Item


type Name
    = KlamathMaidaBuckner
    | DenFlick


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V77.Data.Item.Id Evergreen.V77.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
