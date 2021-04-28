module Evergreen.V71.Data.Vendor exposing (..)

import Dict
import Evergreen.V71.Data.Item


type Name
    = KlamathMaidaBuckner


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V71.Data.Item.Id Evergreen.V71.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
