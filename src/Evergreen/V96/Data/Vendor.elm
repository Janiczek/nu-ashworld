module Evergreen.V96.Data.Vendor exposing (..)

import Dict
import Evergreen.V96.Data.Item


type Name
    = ArroyoHakunin
    | KlamathMaidaBuckner
    | DenFlick
    | ModocJo
    | VaultCityHappyHarry


type alias Vendor =
    { name : Name
    , items : Dict.Dict Evergreen.V96.Data.Item.Id Evergreen.V96.Data.Item.Item
    , caps : Int
    , barterSkill : Int
    }
