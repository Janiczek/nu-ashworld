module Evergreen.V81.Data.Vendor exposing (..)

import Dict
import Evergreen.V81.Data.Item


type Name
    = KlamathMaidaBuckner
    | DenFlick


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V81.Data.Item.Id Evergreen.V81.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
