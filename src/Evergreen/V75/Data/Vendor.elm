module Evergreen.V75.Data.Vendor exposing (..)

import Dict
import Evergreen.V75.Data.Item


type Name
    = KlamathMaidaBuckner
    | DenFlick


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V75.Data.Item.Id Evergreen.V75.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
