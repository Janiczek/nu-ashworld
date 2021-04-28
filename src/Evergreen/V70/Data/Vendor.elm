module Evergreen.V70.Data.Vendor exposing (..)

import Dict
import Evergreen.V70.Data.Item


type Name
    = KlamathMaidaBuckner


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V70.Data.Item.Id Evergreen.V70.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
