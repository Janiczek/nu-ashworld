module Evergreen.V78.Data.Vendor exposing (..)

import Dict
import Evergreen.V78.Data.Item


type Name
    = KlamathMaidaBuckner
    | DenFlick


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V78.Data.Item.Id Evergreen.V78.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
